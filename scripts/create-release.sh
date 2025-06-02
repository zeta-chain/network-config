#!/usr/bin/env bash

# Network Configuration Release Script
# Usage: ./scripts/create-release.sh [version]
# Example: ./scripts/create-release.sh v1.0.0

set -euo pipefail

# Check if version argument is provided
if [ $# -eq 0 ]; then
  echo "❌ Error: Version argument is required!" >&2
  echo "" >&2
  echo "Usage: $0 <version>" >&2
  echo "Example: $0 v1.0.0" >&2
  echo "" >&2
  echo "This prevents accidentally re-releasing old versions." >&2
  exit 1
fi

VERSION="$1"

# Validate version format
if [[ ! "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "❌ Error: Invalid version format!" >&2
  echo "" >&2
  echo "Version must follow the pattern: v#.#.#" >&2
  echo "Examples: v1.0.0, v2.1.0, v1.0.1" >&2
  echo "Provided: $VERSION" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ARTIFACTS_DIR="${ROOT_DIR}/release-artifacts"

echo "Creating release artifacts for version: ${VERSION}"

# Create artifacts directory
mkdir -p "${ARTIFACTS_DIR}"

# Clean previous artifacts for this version (with safeguard and nullglob)
shopt -s nullglob
old_artifacts=("${ARTIFACTS_DIR:?}/"*"${VERSION}"*)
if [ ${#old_artifacts[@]} -gt 0 ]; then
  rm -f "${old_artifacts[@]}"
fi
shopt -u nullglob

# Environment directories to include
ENVIRONMENTS=("athens3" "devnet" "mainnet")
# Specific files to include in each environment
CONFIG_FILES=("config.toml" "app.toml" "genesis.json" "client.toml")

# Create artifacts for each environment
for env in "${ENVIRONMENTS[@]}"; do
  if [ -d "${env}" ]; then
    echo "Creating artifact for ${env}..."

    # Check which files exist and include only those
    FILES_TO_INCLUDE=()
    for file in "${CONFIG_FILES[@]}"; do
      if [ -f "${env}/${file}" ]; then
        FILES_TO_INCLUDE+=("${file}")
        echo "  ✓ Including ${file}"
      else
        echo "  ⚠️  ${file} not found, skipping..." >&2
      fi
    done

    if [ ${#FILES_TO_INCLUDE[@]} -gt 0 ]; then
      tar -C "${env}" -czf "${ARTIFACTS_DIR}/${env}-${VERSION}.tar.gz" "${FILES_TO_INCLUDE[@]}"
      echo "✓ Created ${env}-${VERSION}.tar.gz with ${#FILES_TO_INCLUDE[@]} files"
    else
      echo "❌ No config files found in ${env}, skipping artifact creation..." >&2
    fi
  else
    echo "⚠️  Warning: ${env} directory not found, skipping..." >&2
  fi
done

# Generate checksums using nullglob for better error handling
echo "Generating checksums..."
cd "${ARTIFACTS_DIR}"

# Enable nullglob to handle empty globs gracefully
shopt -s nullglob
files=(*"${VERSION}".tar.gz)
shopt -u nullglob

if ((${#files[@]})); then
  # Use portable checksum utility
  if command -v sha256sum &>/dev/null; then
    sha256sum "${files[@]}" >"checksums-${VERSION}.txt"
  elif command -v shasum &>/dev/null; then
    shasum -a 256 "${files[@]}" >"checksums-${VERSION}.txt"
  else
    echo "❌ Error: No suitable checksum utility found (sha256sum or shasum)" >&2
    exit 1
  fi
else
  echo "❌ No artifacts created, skipping checksum generation" >&2
  exit 1
fi

cd "${ROOT_DIR}"

echo ""
echo "🎉 Release artifacts created successfully!"
echo "📁 Artifacts location: ${ARTIFACTS_DIR}"
echo ""
echo "📦 Generated files:"
ls -la "${ARTIFACTS_DIR}"/*"${VERSION}"*

echo ""
echo "🔍 Checksums:"
cat "${ARTIFACTS_DIR}/checksums-${VERSION}.txt"

echo ""
echo "📝 Next steps:"
echo "1. Review the generated artifacts"
echo "2. Test by extracting and verifying configurations"
echo "3. Create git tag: git tag ${VERSION}"
echo "4. Push tag to trigger automated release: git push origin ${VERSION}"
