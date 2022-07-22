## Install dependencies:
```
cd $HOME
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
git clone https://github.com/Stride-Labs/stride.git
cd stride
git checkout c53f6c562d9d3e098aab5c27303f41ee055572cb
make build
sudo cp $HOME/stride/build/strided /usr/local/bin
```
## Add variobles:
```
echo 'export STRIDE_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export STRIDE_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export STRIDE_CHAIN="STRIDE-1"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $STRIDE_MONIKER
echo $STRIDE_WALLET
echo $STRIDE_CHAIN
```

## Init:
```
strided init $STRIDE_MONIKER --chain-id $STRIDE_CHAIN
```
## Generate keys:
```
strided keys add $STRIDE_WALLET
```
## Download genesis:
```
wget -qO $HOME/.stride/config/genesis.json "https://raw.githubusercontent.com/Stride-Labs/testnet/main/poolparty/genesis.json"
```

## Unsafe restart all:
```
strided tendermint unsafe-reset-all --home ~/.stride
```

## Configure your node:
```
SEEDS="baee9ccc2496c2e3bebd54d369c3b788f9473be9@seedv1.poolparty.stridenet.co:26656"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.stride/config/config.toml
```

## Set minimum gas prices:
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ustrd\"/" $HOME/.stride/config/app.toml
```
## Configure pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.stride/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.stride/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.stride/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.stride/config/app.toml
```
## install service to run the node:
```
sudo tee /etc/systemd/system/strided.service > /dev/null <<EOF
[Unit]
Description=stride
After=network-online.target

[Service]
User=$USER
ExecStart=$(which strided) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable strided
sudo systemctl daemon-reload
sudo systemctl restart strided
sudo systemctl status strided
```

## Check your node logs:
```
journalctl -u strided -f --output cat
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
```
#Join our discord server to access the faucet
```
## Сheck your balance:
```
strided q bank balances $(strided keys show $STRIDE_WALLET -a)
```
## Create validator:
```
strided tx staking create-validator \
 --amount=10000000ustrd \
 --pubkey=$(strided tendermint show-validator) \
 --from=$STRIDE_WALLET \
 --moniker=$STRIDE_MONIKER \
 --chain-id=$STRIDE_CHAIN \
 --details="" \
 --website="" \
 --identity="" \
 --commission-rate=0.08 \
 --commission-max-rate=0.2 \
 --commission-max-change-rate=0.01 \
 --min-self-delegation=1
```

## Check your node status:
```
curl localhost:26657/status
```
## Add liquid stake:
```
strided tx stakeibc liquid-stake 1000 uatom --from $STRIDE_WALLET --chain-id $STRIDE_CHEIN
```
## Collect rewards:
```
strided tx distribution withdraw-all-rewards \
 --chain-id=$STRIDE_CHAIN \
 --from $STRIDE_WALLET
```
## Delegate tokens to your validator:
```
strided tx staking delegate $(stride keys show $STRIDE_WALLET --bech val -a) <amountustrd> \
 --chain-id=$STRIDE_CHAIN \
 --from=$STRIDE_WALLET
```

## Unjail:
```
strided tx slashing unjail \
 --chain-id $STRIDE_CHAIN \
 --from $STRIDE_WALLET 
```
## Stop the node:
```
sudo systemctl stop stride
```
## Delete node files and directories:
```
sudo systemctl stop strided
sudo systemctl disable strided
rm /etc/systemd/system/strided.service
rm -Rvf $HOME/stride
rm -Rvf $HOME/.stride
```
## Official links:
  
[Discord](http://stride.zone/discord)

[Github](https://github.com/Stride-Labs/testnet)

[Explorer 1](https://poolparty.stride.zone/STRIDE/staking)

[Explorer 2](https://stride.explorers.guru/validators)
