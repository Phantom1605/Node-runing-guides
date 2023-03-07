# NIBIRU
This is a script for installing hypersign fullnode

Run the script by command:
```
wget -O nibiru_install.sh https://raw.githubusercontent.com/Phantom1605/Node-runing-guides/main/Nibiru/nibiru-install.sh
```
## Manual install
If you want setting up node manually, you can follow [manual guide](https://github.com/Phantom1605/Node-runing-guides/blob/main/Nibiru/Nibiru-Testnet.md)

## Recover or create new wallet:
* create new wallet:
```
nibid keys add $NIBIRU_WALLET
```
* recover existing wallet:
```
nibid keys add $NIBIRU_WALLET --recover
```
## Faucet:
* You can go to their [application] (https://app.nibiru.fi/), connect your Kepler wallet and request tokens, or do it manually via the terminal.
```
FAUCET_URL="https://faucet.itn-1.nibiru.fi/"
curl -X POST -d '{"address": "'"$ADDR"'", "coins": ["11000000unibi","100000000unusd","100000000uusdt"]}' $FAUCET_URL
```
## Check your balance:
```
nibid q bank balances $(nibid keys show $NIBIRU_WALLET -a)
```
## Create validator:
```
nibid tx staking create-validator \
  --amount 10000000unibi \
  --pubkey  $(nibid tendermint show-validator) \
  --from $NIBIRU_WALLET \
  --moniker $NIBIRU_MONIKER \
  --chain-id $NIBIRU_CHAIN \
  --details="" \
  --website= "" \
  --identity="" \
  --min-self-delegation=1 \
  --commission-max-change-rate=0.1 \
  --commission-max-rate=0.2 \
  --commission-rate=0.1 \
  --gas-prices 0.025unibi
```
## Withdraw rewards:
```
nibid tx distribution withdraw-all-rewards \
 --from $NIBIRU_WALLET
 --chain-id=$NIBIRU_CHAIN
 --gas-prices 0.025unibi
```
## Withdraw validator commission:
```
nibid tx distribution withdraw-rewards $(nibid keys show $NIBIRU_WALLET --bech val -a) \
--chain-id $NIBIRU_CHAIN \
--from $NIBIRU_WALLET \
--gas-prices 0.025unibi \
--commission \
--yes
```
## Delegate tokens to your validator:
```
nibid tx staking delegate $(nibid keys show $DEFUND_WALLET --bech val -a) <amontunibi> \
 --chain-id=$NIBIRU_CHAIN
 --from=$NIBIRU_WALLET
 --gas-prices 0.025unibi
```
## Unjail:
```
nibid tx slashing unjail \
--from $NIBIRU_WALLET \
--chain-id=$NIBIRU_CHAIN \
--gas-prices 0.025unibi
```
## Delete node files and directories:
```
sudo systemctl stop nibidd
sudo systemctl disable nibid
rm /etc/systemd/system/nibid.service
rm -Rvf $HOME/nibiru
rm -Rvf $HOME/.nibid
```
## Official links:

[Discord](https://discord.gg/nibiru)

[Official instructions](https://docs.nibiru.fi/)

[Official site](https://nibiru.fi/)

[NIbiru application](https://app.nibiru.fi/)

## Explorers:
- https://explorer.kjnodes.com/nibiru-testnet/staking
- https://nibiru.explorers.guru/validators
