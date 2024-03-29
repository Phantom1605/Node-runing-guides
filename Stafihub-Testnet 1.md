## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils -y
```
## Install Go:
```
cd $HOME
wget -O go1.18.2.linux-amd64.tar.gz https://go.dev/dl/go1.18.2.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.2.linux-amd64.tar.gz && rm go1.18.2.linux-amd64.tar.gz

cat <<'EOF' >> $HOME/.bash_profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF

. $HOME/.bash_profile
cp /usr/local/go/bin/go /usr/bin
go version
```
## Clone git repository and install:
```
cd $HOME && git clone --branch public-testnet https://github.com/stafihub/stafihub
cd $HOME/stafihub && make install
cp $HOME/go/bin/stafihubd /usr/local/bin
```
## Add variables:
```
echo 'export STAFIHUB_MONIKER='\"${NODE_MONIKER}\" >> $HOME/.bash_profile
echo 'export STAFIHUB_WALLET='\"${YOUR_WALLET}\" >> $HOME/.bash_profile
echo 'export STAFIHUB_CHAIN="stafihub-testnet-1"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $STAFIHUB_MONIKER
echo $STAFIHUB_WALLET
echo $STAFIHUB_CHAIN
```
## Recover or create new wallet:
* create new wallet:
```
stafihubd keys add $STAFIHUB_WALLET
```
* recover existing wallet:
```
stafihub keys add $STAFIHUB_WALLET --recover
```
## Init:
```
stafihubd init $STAFIHUB_MONIKER --chain-id $STAFIHUB_CHAIN --recover
```
## Download genesis:
```
wget -O $HOME/.stafihub/config/genesis.json "https://raw.githubusercontent.com/tore19/network/main/testnets/stafihub-testnet-1/genesis.json"
```
## Unsafe restart all:
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
## Configure pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.sei/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.stafihub/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.stafihub/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.stafihub/config/app.toml
```
## Install service to run the node:
 ```
sudo tee <<EOF >/dev/null /etc/systemd/system/stafihubd.service
[Unit]
Description=StaFiHub Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which stafihubd) start --log_level=info
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable stafihubd
sudo systemctl restart stafihubd
```
## Check your node logs:
```
journalctl -u stafihubd -f
```
## Status of sinchronization:
```
stafihubd status 2>&1 | jq .SyncInfo
```
## Faucet:
You can ask for tokens in the [#faucet](https://discord.gg/uKSdyZ8z) Discord channel.
Send: `!faucet send <YOUR_WALLET_ADDRESS>`

## Сheck your balance:
```
stafihubd q bank balances $(stafihubd keys show $YOUR_TEST_WALLET -a)
```
## Create validator:
```
stafihubd tx staking create-validator \
 --amount=1000000ufis \
 --pubkey=$(stafihubd tendermint show-validator) \
 --from=$STAFIHUB_WALLET \
 --moniker=$STAFIHUB_MONIKER \
 --chain-id=$STAFIHUB_CHAIN \
 --details="" \
 --website=""\
 --identity= ""\
 --commission-rate=0.1 \
 --commission-max-rate=0.2 \
 --commission-max-change-rate=0.01 \
 --min-self-delegation=1 \
 --gas-prices=0.025ufis
 ```
 ## Check your node status:
 ```
 curl localhost:26657/status
 ```
## Delegate tokens to your validator:
```
stafihubd tx staking delegate $(stafihubd keys show $YOUR_TEST_WALLET --bech val -a) <amountufis> \
 --chain-id=$STAFIHUB_CHAIN \
 --from=$STAFIHUB_WALLET \
 --gas auto \
 --gas-adjustment=1.4 \
 --gas-prices=0.025ufis
```
## Collect rewards:
```
stafihubd tx distribution withdraw-all-rewards \
 --chain-id=$STAFIHUB_CHAIN \
 --from $STAFIHUB_WALLET \
 --gas auto \
 --gas-adjustment=1.4 \
 --gas-prices="0.025ufis"
```
## Unjail:
```
stafihubd tx slashing unjail \
 --chain-id $STAFIHUB_CHAIN \ 
 --from $STAFIHUB_WALLET \ 
 --gas=auto \ 
 --gas-adjustment=1.4 \
 --gas-prices="0.025ufis"
```
## Stop the node:
```
sudo systemctl stop stafihubd
```
## Delete node files and directories:
```
sudo systemctl stop stafihubd
sudo systemctl disable stafihubd
rm /etc/systemd/system/stafihubd.service
rm -Rvf $HOME/stafihub
rm -Rvf $HOME/.stafihub
```
## Official links:
[Explorer](https://testnet-explorer.stafihub.io/stafi-hub-testnet/staking)

[Github](https://github.com/stafihub/network/tree/main/testnets)
