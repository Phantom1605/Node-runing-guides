## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils htop -y < "/dev/null" -y
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

## Clone git repository:
```
cd $HOME
git clone https://github.com/ingenuity-build/quicksilver.git --branch v0.4.0
cd quicksilver
git checkout v0.4.0
make build
cp $HOME/quicksilver/build/quicksilverd /usr/local/bin
quicksilverd version
```
## Add variables:
```
echo 'export QUICKSILVER_MONIKER="Your moniker"'>> $HOME/.bash_profile
echo 'export QUICKSILVER_WALLET="Your wallet name"'>> $HOME/.bash_profile
echo 'export QUICKSILVER_CHAIN="killerqueen-1"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $QUICKSILVER_MONIKER
echo $QUICKSILVER_WALLET
echo $QUICKSILVER_CHAIN
```
## Init:
```
quicksilverd init $QUICKSILVER_MONIKER --chain-id $QUICKSILVER_CHAIN
```
## Generate keys:
```
quicksilverd keys add $QUICKSILVER_WALLET --recover
```
## Download genesis:
```
wget -qO $HOME/.quicksilverd/config/genesis.json "https://raw.githubusercontent.com/ingenuity-build/testnets/main/killerqueen/genesis.json"
```
## Set seeds and peers:
```
SEEDS="dd3460ec11f78b4a7c4336f22a356fe00805ab64@seed.killerqueen-1.quicksilver.zone:26656,8603d0778bfe0a8d2f8eaa860dcdc5eb85b55982@seed02.killerqueen-1.quicksilver.zone:27676"
PEERS="b281289df37c5180f9ff278be5e29964afa0c229@185.56.139.84:26656,4f35ab6008fc46cc50b103a337ec2266400eca2e@148.251.50.79:26656,90f4459126152d21983f42c8e86bc899cd618af6@116.202.15.183:11656,6ac91620bc5338e6f679835cc604769a213d362f@139.59.56.24:36366"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.quicksilverd/config/config.toml
```
## Configure pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.quicksilverd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.quicksilverd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.quicksilverd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.quicksilverd/config/app.toml
```
## Set minimum gas price:
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uqck\"/" $HOME/.quicksilverd/config/app.toml
```
Insafe reset all:
```
quicksilverd tendermint unsafe-reset-all --home $HOME/.quicksilverd
```

Install service to run the node:
```
sudo tee /etc/systemd/system/quicksilverd.service > /dev/null <<EOF
[Unit]
Description=quicksilver
After=network-online.target

[Service]
User=$USER
ExecStart=$(which quicksilverd) start
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
## tatus of sinchronization:
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
## Check your balance:
```
quicksilverd q bank balances $(quicksilverd keys show $QUICKSILVER_WALLET -a)
```
## Check your node status:
```
curl localhost:26657/status
```
## Collect rewards:
```
quicksilverd tx distribution withdraw-all-rewards \
--chain-id=$QUICKSILVER_CHAIN \
--from $QUICKSILVER_WALLET
```
## Delegate tokens to your validator:
```
quicksilverd tx staking delegate $(quicksilverd keys show $QUICKSILVER_WALLET --bech val -a) <amountuqck> \
--chain-id=$QUICKSILVER_CHAIN \
--from=$QUICKSILVER_WALLET
```
## Unjail:
```
quicksilverd tx slashing unjail \
--chain-id $QUICKSILVER_CHAIN \ 
--from $QUICKSILVER_WALLET
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
Official links:
[Github](https://github.com/ingenuity-build/testnets)
 
