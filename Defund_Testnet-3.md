## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev curl build-essential git jq ncdu bsdmainutils mc htop -y
```
## Install Go:
```
wget -O go1.19.1.linux-amd64.tar.gz https://golang.org/dl/go1.19.1.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.1linux-amd64.tar.gz && rm go1.19.1linux-amd64.tar.gz

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
git clone https://github.com/defund-labs/defund.git
cd defund
git checkout v0.1.0-alpha
make install
cp $HOME/go/bin/defundd /usr/local/bin
```
## Add variables:
```
echo 'export DEFUND_MONIKER="your node moniker"'>> $HOME/.bash_profile
echo 'export DEFUND_WALLET="your wallet name"'>> $HOME/.bash_profile
echo 'export DEFUND_CHAIN="defund-private-3"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $DEFUND_MONIKER
echo $DEFUND_WALLET
echo $DEFUND_CHAIN
```
## Init:
```
defundd init $DEFUND_MONIKER --chain-id $DEFUND_CHAIN
```
## Recover or create new wallet:
* create new wallet:
```
defundd keys add $DEFUND_WALLET
```
* recover existing wallet:
```
defundd keys add $DEFUND_WALLET --recover
```

## Dowload genesis:
```
wget -O defund-private-3-gensis.tar.gz https://github.com/defund-labs/testnet/raw/main/defund-private-3/defund-private-3-gensis.tar.gz
sudo tar -xvzf defund-private-3-gensis.tar.gz -C $HOME/.defund/config
rm defund-private-3-gensis.tar.gz
```
## Set seeds and peers:
```
SEEDS="85279852bd306c385402185e0125dffeed36bf22@38.146.3.194:26656,09ce2d3fc0fdc9d1e879888e7d72ae0fefef6e3d@65.108.105.48:11256"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.defund/config/config.toml
```
## Set custom ports:
```
DEFUND_PORT=35
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${DEFUND_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${DEFUND_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${DEFUND_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${DEFUND_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${DEFUND_PORT}660\"%" $HOME/.defund/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${DEFUND_PORT}317\"%; s%^address = \":8080\"%address = \":${DEFUND_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${DEFUND_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${DEFUND_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${DEFUND_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${DEFUND_PORT}546\"%" $HOME/.defund/config/app.toml
```
## Config node:
```
defundd config node tcp://localhost:35657
```
## Config pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.defund/config/app.toml
```
## Set minimum gas price:
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ufetf\"/" $HOME/.defund/config/app.toml
```
## Unsefe reset all:
```
defundd tendermint unsafe-reset-all --home ~/.defund
```
## Create servise file:
```
sudo tee /etc/systemd/system/defundd.service > /dev/null <<EOF
[Unit]
Description=defund
After=network-online.target

[Service]
User=$USER
ExecStart=$(which defundd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable defundd
sudo systemctl daemon-defundd
sudo systemctl restart defundd
sudo systemctl status defundd
```
## Check your node logs:
```
sudo journalctl -u defundd -f -o cat
```
## Status of sinchronization:
```
defundd status 2>&1 | jq .SyncInfo
curl http://localhost:35657/status | jq .result.sync_info.catching_up
```
## Check Node ID:
```
curl localhost:35657/status | jq '.result.node_info.id'
```
## Faucet:
* Join to [Discord](https://discord.gg/cfnH9Mrj) and navigate to: #faucet to request test tokens:
```
!request YOUR_WALLET_ADDRESS
```
## Check your balance:
```
defundd q bank balances $(defundd keys show $DEFUND_WALLET -a)
```
## Create validator:
```
defundd tx staking create-validator \
  --amount 2000000ufetf \
  --pubkey  $(defundd tendermint show-validator) \
  --from $DEFUND_WALLET \
  --moniker $DEFUND_MONIKER \
  --chain-id $DEFUND_CHAIN \
  --details="" \
  --website= "" \
  --identity="" \
  --min-self-delegation=1 \
  --commission-max-change-rate=0.01 \
  --commission-max-rate=0.2 \
  --commission-rate=0.07
  ```
  ## Check your node status:
```
curl localhost:26657/status | jq
```
## Withdraw rewards:
```
defundd tx distribution withdraw-all-rewards \
 --from $DEFUND_WALLET
 --chain-id=$DEFUND_CHAIN
 --gas=auto
```
## Withdraw validator commission:
```
defundd tx distribution withdraw-rewards $(defundd keys show $DEFUND_WALLET --bech val -a) \
--chain-id $DEFUND_CHAIN \
--from $DEFUND_WALLET \
--commission \
--yes
```
## Delegate tokens to your validator:
```
defundd tx staking delegate $(defundd keys show $DEFUND_WALLET --bech val -a) <amontufetf> \
 --chain-id=$DEFUND_CHAIN
 --from=$DEFUND_WALLET
 --gas=auto
```
## Unjail:
```
defundd tx slashing unjail \
 --from $DEFUND_WALLET \
 --chain-id=$DEFUND_CHAIN \
 --gas=auto
```
## Stop the node:
```
sudo systemctl stop defundd
```
## Delete node files and directories:
```
sudo systemctl stop defundd
sudo systemctl disable defundd
rm /etc/systemd/system/defundd.service
rm -Rvf $HOME/defund
rm -Rvf $HOME/.defund
```
## Official links:

[Discord](https://discord.gg/cfnH9Mrj)

[Explorer](https://defund.explorers.guru/validators)
