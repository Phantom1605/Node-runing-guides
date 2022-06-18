## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils -y
```

## Install Go:
```
wget -O go1.18.linux-amd64.tar.gz https://go.dev/dl/go1.18.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.linux-amd64.tar.gz && rm go1.18.linux-amd64.tar.gz
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

## Clone git repository:
```
git clone https://github.com/ingenuity-build/quicksilver.git --branch v0.3.0
cd quicksilver
git checkout v0.3.0
make build
cp $HOME/quicksilver/build/quicksilverd /usr/local/bin
quicksilverd version
```

## Add variobles:
```
echo 'export NODE_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export YOUR_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export CHAIN_ID="rhapsody-5"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $YOUR_MONIKER
echo $YOUR_WALLET
echo $CHAIN_ID
```
## Init:
```
quicksilverd init $YOUR_MONIKER --chain-id $CHAIN_ID
```
## Generate keys:
```
quicksilverd keys add $YOUR_WALLET
```

## Download genesis:
```
wget -qO $HOME/.quicksilverd/config/genesis.json "https://raw.githubusercontent.com/ingenuity-build/testnets/main/rhapsody/genesis.json"
```

## Unsafe restart all:
```
quicksilverd tendermint unsafe-reset-all --home ~/.quicksilverd
```

## Configure your node:
```
# Set seeds and peers:
SEEDS="dd3460ec11f78b4a7c4336f22a356fe00805ab64@seed.rhapsody-5.quicksilver.zone:26656"
PEERS="c5cbd164de9c20a13e54e949b63bcae4052a948c@138.201.139.175:20956,9428068507466b542cbf378d59b77746c1d19a34@157.90.35.151:26657,4e7a6d8a3c8eeaad4be4898d8ec3af1cef92e28d@93.186.200.248:26656,eaeb462547cf76c3588e458120097b51db732b14@194.163.155.84:26656,51af5b6b4b0f5b2b53df98ec1b029743973f08aa@75.119.145.20:26656,9a9ed14d71a88354b0383419432ecce70e8cd2b3@161.97.152.215:26656,43bca26cb1b2e7474a8ffa560f210494023d5de4@135.181.140.225:26657"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.quicksilverd/config/config.toml

# Set minimum gas prices:
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uqck\"/" $HOME/.quicksilverd/config/app.toml
```
## Config pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"

sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.quicksilverd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.quicksilverd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.quicksilverd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.quicksilverd/config/app.toml
```
## install service to run the node:
```
sudo tee <<EOF >/dev/null /etc/systemd/system/quicksilverd.service
[Unit]
Description=Quicksilver Cosmos daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which quicksilverd) start --log_level=info
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF


sudo systemctl enable quicksilverd
sudo systemctl daemon-reload
sudo systemctl restart quicksilverd
sudo systemctl status quicksilverd
```
## Check your node logs:
```
journalctl -u quicksilverd -f --output cat
```
## Status of sinchronization:
```
quicksilverd status 2>&1 | jq .SyncInfo

curl http://localhost:26657/status | jq .result.sync_info.catching_up
```
## Check Node ID:
```
curl localhost:26657/status | jq '.result.node_info.id'
```
## Faucet:
```
# Join our discord server to access the faucets for QCK 
```
## Сheck your balance:
```
quicksilverd q bank balances $(quicksilverd keys show $YOUR_WALLET -a)
```
## Create validator:
```
quicksilverd tx staking create-validator \
--amount=<amount>uqck \
--pubkey=$(quicksilverd tendermint show-validator) \
--from=$YOUR_WALLET \
--moniker=$YOUR_MONIKER \
--chain-id=$CHAIN_ID \
--details="" \
--website="" \
--identity="" \
--min-self-delegation=1 \
--commission-rate=0.1 \
--commission-max-rate=0.5 \
--commission-max-change-rate=0.1 \
--gas-prices=0.025uqck \
--gas-adjustment=1.4
```

## Check your node status:
```
curl localhost:26657/status
```
## Collect rewards:
```
quicksilverd tx distribution withdraw-all-rewards \
--chain-id=$CHAIN_ID \
--from $YOUR_TEST_WALLET \
--gas auto \
--gas-adjustment=1.4 \
--gas-prices=0,025uqck
```

## Delegate tokens to your validator:
```
quicksilverd tx staking delegate $(cland keys show $YOUR_WALLET --bech val -a) <amountufis> \
--chain-id=$CHAIN_ID \
--from=$YOUR_WALLET \
--gas auto \
--gas-adjustment=1.4 \
--gas-prices=0,025uqck
```
## Unjail:
```
quicksilverd tx slashing unjail \
--chain-id $CHAIN_ID \ 
--from $YOUR_WALLET \ 
--gas=auto \ 
--gas-adjustment=1.4 \
--gas-prices=0,025uqck
```
## Stop the node:
```
sudo systemctl stop quicksilverd
```
## Delete node files and directories:
```
sudo systemctl stop quicksilverd
sudo systemctl disable quicksilverd
rm /etc/systemd/system/quicksilverd.service
rm -Rvf $HOME/quicksilver
rm -Rvf $HOME/.quicksilverd
```
## Official links:
[Github](https://github.com/ingenuity-build/testnets)
