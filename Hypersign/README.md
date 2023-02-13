# Hypersign
This is a script for installing hypersign fullnode

Run the script by command:
```
wget -O hypersign_install.sh https://raw.githubusercontent.com/Phantom1605/Node-runing-guides/main/Hypersign/hypersign_install.sh && chmod +x hypersign_install.sh && ./hypersign_install.sh
```
## Manual install
If you want setting up node manually, you can follow [manual guide](https://github.com/Phantom1605/Node-runing-guides/blob/main/Hypersign/Hypersign-Testnet.md)

## State Sync:
You can [state sync](https://github.com/Phantom1605/Node-runing-guides/blob/main/Hypersign/State-Sync%20for%20Hypersign.md) your node

## Recover or create new wallet:
* create new wallet:
```
hid-noded keys add $HID_WALLET
```
* recover existing wallet:
```
hid-noded keys add $HID_WALLET --recover
```
## Faucet:
* Join to [Discord](https://discord.gg/kYsKnBKj) and navigate to: #jagart-faucet to request test tokens:
```
$request YOUR_WALLET_ADDRESS
```
## Check your balance:
```
hid-noded q bank balances $(hid-noded keys show $HID_WALLET -a)
```
## Create validator:
```
hid-noded tx staking create-validator \
  --amount 100000000uhid \
  --pubkey  $(hid-noded tendermint show-validator) \
  --from $HID_WALLET \
  --moniker $HID_MONIKER \
  --chain-id $HID_CHAIN \
  --details="" \
  --website= "" \
  --identity="" \
  --min-self-delegation=1 \
  --commission-max-change-rate=0.01 \
  --commission-max-rate=0.2 \
  --commission-rate=0.06
  ```
  ## Delegate tokens to your validator:
```
hid-noded tx staking delegate $(hid-noded keys show $HID_WALLET --bech val -a) <amounuhid> \
 --chain-id=$HID_CHAIN \
 --from=$HID_WALLET
```
## Withdraw rewards:
```
hid-noded tx distribution withdraw-all-rewards \
 --chain-id=$HID_CHAIN \
 --from $HID_WALLET
```
## Unjail:
```
hid-noded tx slashing unjail \
 --chain-id $HID_CHAIN \
 --from $HID_WALLET
```
## Stop the node:
```
sudo systemctl stop hid-noded
```
## Delete node files and directories:
```
sudo systemctl stop hid-noded
sudo systemctl disable hid-noded
rm /etc/systemd/system/hid-noded.service
rm -Rvf $HOME/hid-node
rm -Rvf $HOME/.hid-node
```
## Official links:

[Github](https://github.com/hypersign-protocol)

[Official website](https://hypersign.id)

[Discord](https://discord.gg/kYsKnBKj)
