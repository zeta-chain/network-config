# Create Gentx

To join the network at genesis you need to provide your operator address and pubkey from your validator

## Download or build the binary for your system

https://github.com/zeta-chain/node/releases

## Add your operator wallet

- This guides assumes you are using a ledger device and the key name is `operator`
- If you are not you can exclude `--ledger --hd-path ""`

```
zetacored keys add operator --ledger --hd-path ""


```

## Create gentx

- Init a new genesis file and create the gentx
- You must self delegate 10 ZETA (10000000000000000000azeta). More will be delegated to you after the public launch

```
ADDRESS=$(zetacored keys show operator -a)
BALANCE="10000000000000000000azeta" # 10 ZETA
MONIKER="YOUR_VALIDATOR_NAME_HERE"
zetacored init "$MONIKER" --chain-id="zetachain_7000-1" # This is a temporary genenesis file and will be replaced later
zetacored add-genesis-account $ADDRESS $BALANCE
zetacored gentx operator 10000000000000000000azeta --chain-id=zetachain_7000-1 --security-contact <your-security-contact-email>
zetacored validate-genesis
```

## Copy Gentx files back to this directory

```
mkdir -p ./genesis_files/gentx/
FILENAME=$(~/.zetacored/config/gentx/)
cp $FILENAME ./genesis_files/gentx/gentx-$MONIKER.json
git add ./genesis_files/gentx/*
git commit -m "Gentx files for $MONIKER"
```

## Create PR

- Use `gen-files-<YourValidatorName>` as the branch name for the new branch.
- The pr must contain only the gentx files
  - `gentx-XX.json`
- Do not commit `network_files/config/genesis.json` if it exists
  - This file can be deleted, it is not required.
- An automated GitHub Action will validator your PR
- Your PR must pass this check before the coordinator will merge it
