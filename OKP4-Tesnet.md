## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev curl build-essential git jq ncdu bsdmainutils mc htop -y
```
## Install Go:
```
wget -O go1.18.2.linux-amd64.tar.gz https://golang.org/dl/go1.18.2.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.2linux-amd64.tar.gz && rm go1.18.2linux-amd64.tar.gz

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
git clone https://github.com/okp4/okp4d.git
cd okp4d
git checkout v2.2.0
make install
cp $HOME/go/bin/okp4d /usr/local/bin
```
## Add variables:
```
echo 'export DEFUND_MONIKER="your node moniker"'>> $HOME/.bash_profile
echo 'export DEFUND_WALLET="your wallet name"'>> $HOME/.bash_profile
echo 'export DEFUND_CHAIN="okp4-nemeton"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $OKP4_MONIKER
echo $OKP4_WALLET
echo $OKP4_CHAIN
```
## Init:
```
okp4d init $OKP4_MONIKER --chain-id $OKP4_CHAIN
```
## Recover or create new wallet:
* create new wallet:
```
okp4d keys add $OKP4_WALLET
```
* recover existing wallet:
```
okp4d keys add $OKP4_WALLET --recover
```

## Dowload genesis:
```
wget -qO $HOME/.okp4d/config/genesis.json "https://raw.githubusercontent.com/okp4/networks/main/chains/nemeton/genesis.json"
```
## Set seeds and peers:
```
SEEDS="8e1590558d8fede2f8c9405b7ef550ff455ce842@51.79.30.9:26656,bfffaf3b2c38292bd0aa2a3efe59f210f49b5793@51.91.208.71:26656,106c6974096ca8224f20a85396155979dbd2fb09@198.244.141.176:26656,a7f1dcf7441761b0e0e1f8c6fdc79d3904c22c01@38.242.150.63:36656"
PEERS="994c9398e55947b2f1f45f33fbdbffcbcad655db@okp4-testnet.nodejumper.io:29656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.okp4d/config/config.toml
```
## Set custom ports:
```
OKP4_PORT=36
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${OKP4_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${OKP4_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${OKP4_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${OKP4_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${OKP4_PORT}660\"%" $HOME/.okp4d/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${OKP4_PORT}317\"%; s%^address = \":8080\"%address = \":${OKP4_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${OKP4_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${OKP4_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${OKP4_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${OKP4_PORT}546\"%" $HOME/.okp4d/config/app.toml
```
## Config node:
```
okp4d config node tcp://localhost:36657
```
## Config pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.okp4d/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.okp4d/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.okp4d/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.okp4d/config/app.toml
```
## Set minimum gas price:
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uknow\"/" $HOME/.okp4d/config/app.toml
```
## Unsefe reset all:
```
okp4d tendermint unsafe-reset-all --home ~/.defund
```
## Create servise file:
```
sudo tee /etc/systemd/system/defundd.service > /dev/null <<EOF
[Unit]
Description=okp4
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

sudo systemctl enable okp4d
sudo systemctl daemon-okp4d
sudo systemctl restart okp4d
sudo systemctl status okp4d
```
## Check your node logs:
```
sudo journalctl -u okp4 -f -o cat
```
## Status of sinchronization:
```
defundd status 2>&1 | jq .SyncInfo
curl http://localhost:36657/status | jq .result.sync_info.catching_up
```
## Check Node ID:
```
curl localhost:36657/status | jq '.result.node_info.id'
```
## Faucet:
* Join to [Discord](https://discord.gg/okp4) and navigate to: #faucet to request test tokens:
```
/request address:YOUR_WALLET_ADDRESS
```
## Check your balance:
```
okp4d q bank balances $(okp4d keys show $OKP4_WALLET -a)
```
## Create validator:
```
okp4d tx staking create-validator \
  --amount 2000000uknow \
  --pubkey  $(okp4d tendermint show-validator) \
  --from $OKP4_WALLET \
  --moniker $OKP4_MONIKER \
  --chain-id $OKP4_CHAIN \
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
curl localhost:36657/status | jq
```
## Withdraw rewards:
```
okp4d tx distribution withdraw-all-rewards \
 --from $OKP4_WALLET
 --chain-id=$OKP4_CHAIN
 --gas=auto
```
## Withdraw validator commission:
```
okp4d tx distribution withdraw-rewards $(okp4d keys show $OKP4_WALLET --bech val -a) \
--chain-id $OKP4_CHAIN \
--from $OKP4_WALLET \
--commission \
--yes
```
## Delegate tokens to your validator:
```
okp4d tx staking delegate $(okp4dd keys show $OKP4_WALLET --bech val -a) <amontuknow> \
 --chain-id=$OKP4_CHAIN
 --from=$OKP4_WALLET
 --gas=auto
```
## Unjail:
```
okp4d tx slashing unjail \
 --from $OKP4_WALLET \
 --chain-id=$OKP4_CHAIN \
 --gas=auto
```
## Stop the node:
```
sudo systemctl stop okp4d
```
## Delete node files and directories:
```
sudo systemctl stop okp4d
sudo systemctl disable okp4d
rm /etc/systemd/system/okp4d.service
rm -Rvf $HOME/okp4
rm -Rvf $HOME/.okp4d
```
## Official links:
[Discord](https://discord.gg/okp4)

[Official instruktions](https://docs.okp4.network/docs/nodes/run-node)

[Explorer](https://okp4.explorers.guru/validators)
