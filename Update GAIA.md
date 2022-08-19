## Clone git repository and install:
```
sudo systemctl stop gaiad
cd $HOME
git clone https://github.com/Stride-Labs/gaia.git
cd gaia
git checkout 5b47714dd5607993a1a91f2b06a6d92cbb504721
make build
cp $HOME/gaia/build/gaiad /usr/local/bin
```
## Unsafe restart all:
```
gaiad tendermint unsafe-reset-all --home ~/.gaiad
```
## Update Genesis:
```
wget -O $HOME/.gaia/config/genesis.json "https://raw.githubusercontent.com/Stride-Labs/testnet/main/poolparty/gaia/gaia_genesis.json"
```
## Restart node:
```
systemctl restart gaiad && journalctl -u gaiad -f -o cat
```
## Check your balance:
```
gaiad q bank balances $(gaiad keys show $GAIA_WALLET -a)
```
## Faucet:
Join to [Discord](http://stride.zone/discord) and navigate to:

* #token-faucet to request test tokens
```
$faucet-atom:<you gaia wallet address>
```

## Check your balance:
```
gaiad q bank balances $(gaiad keys show $GAIA_WALLET -a)
```
## Create validator:
```
gaiad tx staking create-validator \
  --amount=1000000uatom \
  --from $GAIA_WALLET \
  --commission-max-change-rate=0.01 \
  --commission-max-rate=0.2 \
  --commission-rate=0.08 \
  --min-self-delegation=1 \
  --details="" \
  --website="" \
  --identity=""\
  --pubkey=$(gaiad tendermint show-validator) \
  --moniker=$GAIA_MONIKER \
  --chain-id=$GAIA_CHAIN
  ```
  ## Check your node status:
```
curl localhost:26652/status
```
## Collect rewards:
```
gaiad tx distribution withdraw-all-rewards \
  --chain-id=$GAIA_CHAIN \
  --from $GAIA_WALLET
```

## Delegate tokens to your validator:
```
gaiad tx staking delegate gaiad keys show $GAIA_WALLET --bech val -a) 1000000uatom \
  --chain-id=$GAIA_CHAIN \
  --from=$GAIA_WALLET
```
## Unjail:
```
gaiad tx slashing unjail \
--chain-id $GAIA_CHAIN \ 
--from $GAIA_WALLET
```
## Stop the node:
```
sudo systemctl stop gaiad
```
## Delete node files and directories:
```
sudo systemctl stop gaiad
sudo systemctl disable gaiad
rm /etc/systemd/system/junod.service
rm -Rvf $HOME/gaia
rm -Rvf $HOME/.gaia
```
  ## Official links:

[Discord](http://stride.zone/discord)

[Explorer](https://poolparty.stride.zone/GAIA/staking)
