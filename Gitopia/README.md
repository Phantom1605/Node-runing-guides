# Gitopia
This is a script for installing hypersign fullnode

Run the script by command:
```
wget -O gitopia_install.sh https://raw.githubusercontent.com/Phantom1605/Node-runing-guides/main/Gitopia/gitopia_install.sh && chmod +x gitopia_install.sh && ./gitopia_install.sh
```
## Manual install
If you want setting up node manually, you can follow [manual guide](https://github.com/Phantom1605/Node-runing-guides/blob/main/Gitopia/Gitopia-Testnet.md)

## Recover or create new wallet:
* create new wallet:
```
gitopiad keys add $GITOPIA_WALLET
```
* recover existing wallet:
```
gitopiad keys add $GITOPIA_WALLET --recover
```
## Now insert the mnemonic that you saved into the Keplr wallet.
* We go to [gitopia website](https://gitopia.com/home), subtract Keplr and request tokens for it.

## Check your balance:
```
gitopiad q bank balances $(gitopiad keys show $GITOPIA_WALLET -a)
```
## Create validator:
```
gitopiad tx staking create-validator \
--amount=10000000utlore \
--pubkey=$(gitopiad tendermint show-validator) \
--from=$GITOPIA_WALLET \
--moniker=$GITOPIA_MONIKER \
--chain-id=$GITOPIA_CHAIN \
--details="" \
--website="" \
--identity="" \
--commission-rate=0.06 \
--commission-max-rate=0.2 \
--commission-max-change-rate=0.1 \
--min-self-delegation=1
```
## Withdraw rewards:
```
gitopiad tx distribution withdraw-all-rewards \
--from $GITOPIA_WALLET
--chain-id=$GITOPIA_CHAIN
--gas=auto
```
## Withdraw validator commission:
```
gitopiad tx distribution withdraw-rewards $(gitopiad keys show $GITOPIA_WALLET --bech val -a) \
--chain-id $GITOPIA_CHAIN \
--from $GITOPIA_WALLET \
--commission \
--yes
```
## Delegate tokens to your validator:
```
gitopiad tx staking delegate $(gitopiad keys show $GITOPIA_WALLET --bech val -a) <amontutlore> \
--chain-id=$GITOPIA_CHAIN
--from=$GITOPIA_WALLET
--gas=auto
```
## Unjail:
```
gitopiad tx slashing unjail \
--from $GITOPIA_WALLET \
--chain-id=$GITOPIA_CHAIN \
--gas=auto
```
## Delete node files and directories:
```
sudo systemctl stop gitopiad
sudo systemctl disable gitopiad
rm /etc/systemd/system/gitopiad.service
rm -Rvf $HOME/gitopia
rm -Rvf $HOME/.gitopia
```
## Official links:

[Discord](https://discord.gg/JyfJN477)

[Official instructions](https://docs.gitopia.com/validator-overview)

## Explorers:

- https://explorer.gitopia.com/validators

- https://gitopia.explorers.guru/validators
