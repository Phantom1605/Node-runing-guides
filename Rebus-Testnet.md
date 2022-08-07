## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils gcc mc nano chrony -y
```
## Install Go:
```
wget -O go1.18.2.linux-amd64.tar.gz https://golang.org/dl/go1.18.2.linux-amd64.tar.gz
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
cd $HOME
git clone https://github.com/rebuschain/rebus.core.git 
cd rebus.core && git checkout v0.0.3
make install
cp $HOME/go/bin/rebusd /usr/local/bin
```
## Add variables:
```
echo 'export REBUS_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export REBUS_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export REBUS_CHAIN="reb_3333-1"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $REBUS_MONIKER
echo $REBUS_WALLET
echo $REBUS_CHAIN
```
## Init:
```
rebusd init $REBUS_MONIKER --chain-id $REBUS_CHAIN
```
## Generate keys:
```
rebusd keys add $REBUS_WALLET
```
## Download genesis:
```
wget -qO $HOME/.rebusd/config/genesis.json "https://raw.githubusercontent.com/rebuschain/rebus.testnet/master/rebus_3333-1/genesis.json"
```
## Unsafe restart all:
```
rebusd tendermint unsafe-reset-all --home ~/.rebus
```

## Set seeds and peers:
```
SEEDS="a6d710cd9baac9e95a55525d548850c91f140cd9@3.211.101.169:26656,c296ee829f137cfe020ff293b6fc7d7c3f5eeead@54.157.52.47:26656"
PEERS="1ae3fe91ec7aba98eba3aa472453a92aa0a38c04@116.202.169.22:28656,289b378944a9983dc7f6ed6b09ba4a30d8290ee1@148.251.53.155:28656,f2cf370ecff71c0e95b0970f3b2821ea11b66a40@195.201.165.123:20106,1f40e130d2c21a32b0d678eabddc45ec3d6964a2@138.201.127.91:26674,82fc54cd4f7cbb44ee5e9d0565d40b5b29475974@88.198.242.163:46656,bdb21276daf5cc3672ddf5597c68c61dc44ec8e5@212.154.90.211:21656,bcf1b8d1896031da70f5bd1d634d10591d066b1c@5.161.128.219:28656,8abcf4cbdfa413f310e792f31aa54e82e9e09a0c@38.242.131.51:26656,eb47d2414351c010c8f747701f184cf3f8a30181@79.143.179.196:16656,f084e8960bb714c3446796cb4738e78bc5c3f04b@65.109.18.179:31656,34dde0a9cac6aeecc3e6570b59a0d297ab64f5bd@65.108.126.46:31656,d5c87b9a13a3d5be1456e9d982c1fc0fe71d8723@38.242.156.72:26656,d4ac8ea1bc083d6348997fda833ffcf5b150bd92@38.242.156.132:26656,d1a72df36686394e99ff0fff006d58f042692699@161.97.136.177:21656,c2368a4db640aa26fb8d5bc9d0f331758d42ca86@141.95.65.26:28656,9f601f082beb325abf3b6b08cdf27374c8a29469@38.242.206.198:56656,64f998cfa053619f1c755fdb6b7e431ae7c0c7b3@95.217.89.23:30530"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.rebusd/config/config.toml
```

## Set minimum gas prices:
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0arebus\"/" $HOME/.rebusd/config/app.toml
```
## Set commit timeout
```
timeout_commit="2s"
sed -i.bak -e "s/^timeout_commit *=.*/timeout_commit = \"$timeout_commit\"/" $HOME/.rebusd/config/config.toml
```
## Configure pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.rebusd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.rebusd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.rebusd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.rebusd/config/app.toml
```
## install service to run the node:
```
sudo tee /etc/systemd/system/rebusd.service > /dev/null <<EOF
[Unit]
Description=rebus
After=network-online.target

[Service]
User=$USER
ExecStart=$(which rebusd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable rebusd
sudo systemctl daemon-reload
sudo systemctl restart rebusd
sudo systemctl status rebusd
```

## Check your node logs:
```
journalctl -u rebusd -f --output cat
```
## Status of sinchronization:
```
strided status 2>&1 | jq .SyncInfo
curl http://localhost:26657/status | jq .result.sync_info.catching_up
```
## Check Node ID: node_id:
```
curl localhost:26657/status | jq '.result.node_info.id'
```
## Faucet:
Join to [Discord](https://discord.gg/pNZCWv2D ) and navigate to:
* #faucet to request test tokens
```
$request <your wallet address>
```
## Check your balance:
```
rebusd q bank balances $(rebusd keys show $REBUS_WALLET -a)
```
## Create validator:
```
rebusd tx staking create-validator \
 --amount=1000000000000000000arebus \
 --pubkey=$(rebusd tendermint show-validator) \
 --from=$REBUS_WALLET \
 --moniker=$REBUS_MONIKER \
 --chain-id=$REBUS_CHAIN \
 --details="" \
 --website= "" \
 --identity="" \
 --commission-rate=0.08 \
 --commission-max-rate=0.2 \
 --commission-max-change-rate=0.01 \
 --min-self-delegation=1
```
## Check your node status:
```
curl localhost:26657/status | jq
```
## Collect rewards:
```
rebus tx distribution withdraw-all-rewards \
 --chain-id=$REBUS_CHAIN \
 --from $REBUS_WALLET
```
## Delegate tokens to your validator:
```
rebusd tx staking delegate $(rebusd keys show $STRIDE_WALLET --bech val -a) <amontarebus> \
 --chain-id=$REBUS_CHAIN \
 --from=$REBUS_WALLET
```
## Unjail:
```
rebusd tx slashing unjail \
 --chain-id $REBUS_CHAIN \
 --from $REBUS_WALLET 
```
## Stop the node:
```
sudo systemctl stop rebusd
```
## Delete node files and directories:
```
sudo systemctl stop rebusd
sudo systemctl disable rebusd
rm /etc/systemd/system/rebusd.service
rm -Rvf $HOME/rebus
rm -Rvf $HOME/.rebusd
```
## Official links:

[Official docs](https://github.com/rebuschain/rebus.testnet/tree/master/rebus_3333-1)
  
[Discord](https://discord.gg/pNZCWv2D)

[Github](https://github.com/rebuschain)

[Explorer](https://rebus.explorers.guru/validators)
