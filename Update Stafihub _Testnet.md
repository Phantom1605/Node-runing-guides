## Delete stafihub directory:
```
rm -Rvf $HOME/stafihub
```
## Clone git repository and Install:
```
cd $HOME && git clone --branch public-testnet-v3 https://github.com/stafihub/stafihub
cd $HOME/stafihub && make install
cp $HOME/go/bin/stafihubd /usr/local/bin
```
## Change name of the network:
```
nano $HOME/.bash_profile
export CHAIN_ID="stafihub-public-testnet-3"
```
## Download genesis:
```
wget -O $HOME/.stafihub/config/genesis.json "https://raw.githubusercontent.com/stafihub/network/main/testnets/stafihub-public-testnet-3/genesis.json"
```
Unsafe reset all:
```
stafihubd tendermint unsafe-reset-all --home ~/.stafihub
```
## Configure your node:
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.01ufis\"/" $HOME/.stafihub/config/app.toml
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.stafihub/config/app.toml
peers="4e2441c0a4663141bb6b2d0ea4bc3284171994b6@46.38.241.169:26656,79ffbd983ab6d47c270444f517edd37049ae4937@23.88.114.52:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.stafihub/config/config.toml
```
## Restart the node:
```
sudo systemctl restart stafihubd
```
## Check your node logs:
```
journalctl -u stafihubd -f --output cat
```
## Status of sinchronization:
```
stafihubd status 2>&1 | jq .SyncInfo
```
## Create new wallet to top it up in the discord (the old wallet is not replenished):
```
stafihubd keys add New_Wallet
```
## Transfer tokens from the new wallet to the old one:
```
stafihubd tx bank send <sender> <receiver> <amount>ufis --chain-id=$chainName --gas-prices=0.025ufis --gas=auto --gas-adjustment=1.4
```

## Faucet:
You can ask for tokens in the #faucet Discord channel. Send: !faucet send <YOUR_WALLET_ADDRESS>

## Сheck your balance:
```
stafihubd q bank balances $(stafihubd keys show $YOUR_TEST_WALLET -a)
```
## Create validator:
```
stafihubd tx staking create-validator \
 --amount=<amount>ufis \
 --broadcast-mode=block \
 --pubkey=$(stafihubd tendermint show-validator) \
 --moniker=$NODE_MONIKER \
 --details="" \
 --website="" \
 --identity="" \
 --commission-rate=0.07 \
 --commission-max-rate=0.20 \
 --commission-max-change-rate=0.01 \
 --min-self-delegation=1 \
 --from=$YOUR_TEST_WALLET \
 --chain-id=$CHAIN_ID \
 --gas-prices=0.025ufis \
 --gas=auto \
 --gas-adjustment=1.4
```
## Status of your validator:
```
curl localhost:26657/status
```
## Official links:
[Explorer](https://testnet.explorer.testnet.run/Quicksilver/gov)

[Github](https://github.com/stafihub/network/tree/main/testnets)
