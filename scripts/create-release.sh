#!/bin/bash

# Network Configuration Release Script
# Usage: ./scripts/create-release.sh [version]
# Example: ./scripts/create-release.sh v1.0.0

set -euo pipefail

# Check if version argument is provided
if [ $# -eq 0 ]; then
  echo "❌ Error: Version argument is required!"
  echo ""
  echo "Usage: $0 <version>"
  echo "Example: $0 v1.0.0"
  echo ""
  echo "This prevents accidentally re-releasing old versions."
  exit 1
fi

VERSION="$1"

# Validate version format
if [[ ! "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "❌ Error: Invalid version format!"
  echo ""
  echo "Version must follow the pattern: v#.#.#"
  echo "Examples: v1.0.0, v2.1.0, v1.0.1"
  echo "Provided: $VERSION"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ARTIFACTS_DIR="${ROOT_DIR}/release-artifacts"

echo "Creating release artifacts for version: ${VERSION}"

# Create artifacts directory
mkdir -p "${ARTIFACTS_DIR}"

# Clean previous artifacts for this version
rm -f "${ARTIFACTS_DIR}"/*"${VERSION}"*

# Environment directories to include
ENVIRONMENTS=("athens3" "devnet" "mainnet")
# Specific files to include in each environment
CONFIG_FILES=("config.toml" "app.toml" "genesis.json" "client.toml")

cd "${ROOT_DIR}"

# Create artifacts for each environment
for env in "${ENVIRONMENTS[@]}"; do
  if [ -d "${env}" ]; then
    echo "Creating artifact for ${env}..."

    cd "${env}"

    # Check which files exist and include only those
    FILES_TO_INCLUDE=()
    for file in "${CONFIG_FILES[@]}"; do
      if [ -f "${file}" ]; then
        FILES_TO_INCLUDE+=("${file}")
        echo "  ✓ Including ${file}"
      else
        echo "  ⚠️  ${file} not found, skipping..."
      fi
    done

    if [ ${#FILES_TO_INCLUDE[@]} -gt 0 ]; then
      tar -czf "${ARTIFACTS_DIR}/${env}-${VERSION}.tar.gz" "${FILES_TO_INCLUDE[@]}"
      echo "✓ Created ${env}-${VERSION}.tar.gz with ${#FILES_TO_INCLUDE[@]} files"
    else
      echo "❌ No config files found in ${env}, skipping artifact creation..."
    fi

    cd "${ROOT_DIR}"
  else
    echo "⚠️  Warning: ${env} directory not found, skipping..."
  fi
done

# Generate checksums
echo "Generating checksums..."
cd "${ARTIFACTS_DIR}"
if ls *"${VERSION}".tar.gz 1>/dev/null 2>&1; then
  sha256sum *"${VERSION}".tar.gz >"checksums-${VERSION}.txt"
else
  echo "❌ No artifacts created, skipping checksum generation"
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
