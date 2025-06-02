# network-config

This repository is the authoritative source for Zetachain node setup, offering essential configuration files, genesis files, and upgrade paths for all networks. It ensures consistent and reliable node deployment and maintenance.

Please be sure to use the https://docs.zetachain.com docs on how to start a node.

## Releases

This repository uses versioned releases to distribute network configuration files. Each release contains configuration packages for:

- **Athens3** - Testnet configuration
- **Devnet** - Development network configuration
- **Mainnet** - Production network configuration

### Using Released Configurations

1. Download the appropriate configuration package from the [Releases](../../releases) page
2. Extract the configuration files:

   ```bash
   # For Athens3 testnet
   tar -xzf athens3-v1.0.0.tar.gz

   # For Devnet
   tar -xzf devnet-v1.0.0.tar.gz

   # For Mainnet
   tar -xzf mainnet-v1.0.0.tar.gz
   ```

3. Verify the integrity (optional):
   ```bash
   sha256sum -c checksums.txt
   ```

### Configuration Files Included

Each release package contains the following essential configuration files with optimized values:

- `config.toml` - Node configuration
- `app.toml` - Application configuration
- `genesis.json` - Network genesis state
- `client.toml` - Client configuration

### Creating a Release

For maintainers, to create a new release:

1. **Local testing** (optional):

   ```bash
   ./scripts/create-release.sh v1.1.0
   ```

2. **Create and push a git tag**:

   ```bash
   git tag v1.1.0
   git push origin v1.1.0
   ```

3. **Automated release**: The GitHub Action will automatically create the release with artifacts.

### Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed release notes and version history.
