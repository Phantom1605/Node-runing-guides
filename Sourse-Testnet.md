## Install dependencies:
```
cd $HOME
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev libleveldb-dev jq build-essential bsdmainutils git make ncdu htop nano mc screen unzip bc fail2ban -y
```

## Install Go:
```
wget -O go1.18.3.linux-amd64.tar.gz https://golang.org/dl/go1.18.3.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.3.linux-amd64.tar.gz && rm go1.18.3.linux-amd64.tar.gz

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
git clone -b testnet https://github.com/Source-Protocol-Cosmos/source.git
cd source
make install
sudo cp $HOME/go/bin/sourced /usr/local/bin
```
## Add variables:
```
echo 'export SOURCE_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export SOURCE_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export SOURCE_CHAIN="sourcechain-testnet"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $SOURCE_MONIKER
echo $SOURCE_WALLET
echo $SOURCE_CHAIN
```

## Init:
```
sourced init $SOURCE_MONIKER --chain-id $SOURCE_CHAIN
```
## Generate keys:
```
sourced keys add $SOURCE_WALLET
```
## Download genesis:
```
curl -s  https://raw.githubusercontent.com/Source-Protocol-Cosmos/testnets/master/sourcechain-testnet/genesis.json > ~/.source/config/genesis.json
```

## Unsafe restart all:
```
sourced tendermint unsafe-reset-all --home ~/.source
```

## Configure your node:
```
external_address=$(wget -qO- eth0.me) 
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.source/config/config.toml

peers="6ca675f9d949d5c9afc8849adf7b39bc7fccf74f@164.92.98.17:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.source/config/config.toml

seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.source/config/config.toml

sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $HOME/.source/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $HOME/.source/config/config.toml
```

## Set minimum gas prices:
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0usource\"/;" ~/.source/config/app.toml
```
## Configure pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.source/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.source/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.source/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.source/config/app.toml
```
## install service to run the node:
```
sudo tee /etc/systemd/system/sourced.service > /dev/null <<EOF
[Unit]
Description=source
After=network-online.target

[Service]
User=$USER
ExecStart=$(which sourced) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable sourced
sudo systemctl daemon-reload
sudo systemctl restart sourced
sudo systemctl status sourced
```

## Check your node logs:
```
journalctl -u sourced -f --output cat
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
Join to [Discord](https://discord.gg/bE2jcbSa) and navigate to:

* #faucet to request test tokens
```
$request <you source wallet address>
```
## Сheck your balance:
```
sourced q bank balances $(sourced keys show $SOURCE_WALLET -a)
```
## Create validator:
```
sourced tx staking create-validator \
 --amount=1000000usource \
 --pubkey=$(sourced tendermint show-validator) \
 --from=$SOURCE_WALLET \
 --moniker=$SOURCE_MONIKER \
 --chain-id=$SOURCE_CHAIN \
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
## Collect rewards:
```
sourced tx distribution withdraw-all-rewards \
 --chain-id=$SOURCE_CHAIN \
 --from $SOURCE_WALLET
```
## Delegate tokens to your validator:
```
sourced tx staking delegate $(sourced keys show $SOURCE_WALLET --bech val -a) <amountusource> \
 --chain-id=$SOURCE_CHAIN \
 --from=$SOURCE_WALLET
```

## Unjail:
```
sourced tx slashing unjail \
 --chain-id $SOURCE_CHAIN \
 --from $SOURCE_WALLET 
```
## Stop the node:
```
sudo systemctl stop source
```
## Delete node files and directories:
```
sudo systemctl stop sourced
sudo systemctl disable sourced
rm /etc/systemd/system/sourced.service
rm -Rvf $HOME/source
rm -Rvf $HOME/.source
```
## Official links:
  
[Discord](https://discord.gg/bE2jcbSa)

[Website](https://www.sourceprotocol.io)

[Explorer 1](https://explorer.testnet.sourceprotocol.io/source/staking)

[Explorer 2](https://exp.nodeist.net/Source/staking)
