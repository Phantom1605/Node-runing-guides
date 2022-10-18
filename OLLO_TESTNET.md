## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
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
git clone https://github.com/OllO-Station/ollo.git
cd ollo
make install
cp $HOME/go/bin/ollod /usr/local/bin
ollod version
```
## Add variables:
```
echo 'export OLLO_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export OLLO_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export OLLO_CHAIN="ollo-testnet-0"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $OLLO_MONIKER
echo $OLLO_WALLET
echo $OLLO_CHAIN
```
## Init:
```
ollod init $OLLO_MONIKER --chain-id $OLLO_CHAIN
```
## Recover or create new wallet:
* create new wallet:
```
ollod keys add $NOISE_WALLET
```
* recover existing wallet:
```
ollod keys add $NOISE_WALLET --recover
```
## Download genesis:
```
curl https://raw.githubusercontent.com/OllO-Station/ollo/master/networks/ollo-testnet-0/genesis.json | jq .result.genesis > $HOME/.ollo/config/genesis.json
```
## Unsafe restart all
```
ollod tendermint unsafe-reset-all --home ~/.ollo
```
## Set seeds and peers:
```
SEEDS=""
PEERS="2a8f0fada8b8b71b8154cf30ce44aebea1b5fe3d@145.239.31.245:26656,1173fe561814f1ecb8b8f19d1769b87cd576897f@185.173.157.251:26656,489daf96446f104d822fae34cd4aa7a9b5cebf65@65.21.131.215:26626,f43435894d3ae6382c9cf95c63fec523a2686345@167.235.145.255:26656,2eeb90b696ba9a62a8ad9561f39c1b75473515eb@77.37.176.99:26656,9a3e2725e02d1c420a5d500fa17ce0ef45ddc9e8@65.109.30.117:29656,91f1889f22975294cfbfa0c1661c63150d2b9355@65.108.140.222:30656,d38fcf79871189c2c430473a7e04bd69aeb812c2@78.107.234.44:16656,f795505ac42f18e55e65c02bb7107b08d83ad837@65.109.17.86:37656,6368702dd71e69035dff6f7830eb45b2bae92d53@65.109.57.161:15656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.ollo/config/config.toml
```
## Set minimum gas prices:
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0umpwr\"/" ~/.ollo/config/app.toml
```
## Set custom ports:
```
OLLO_PORT=16
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${OLLO_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${OLLO_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${OLLO_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${OLLO_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${OLLO_PORT}660\"%" $HOME/.ollo/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${OLLO_PORT}317\"%; s%^address = \":8080\"%address = \":${OLLO_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${OLLO_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${OLLO_PORT}091\"%" $HOME/.ollo/config/app.toml
```
## Config node:
```
ollod config node tcp://localhost:16657
```
## Configure pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.ollo/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.ollo/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.ollo/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.ollo/config/app.toml
```
## Disable indexing:
```
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.ollo/config/config.toml
```
## Install service file to run the node:
```
sudo tee /etc/systemd/system/ollod.service > /dev/null <<EOF
[Unit]
Description=ollo
After=network-online.target

[Service]
User=$USER
ExecStart=$(which ollod) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable ollod
sudo systemctl daemon-reload
sudo systemctl restart ollod
sudo systemctl status ollod
```
## Check your node logs:
```
sudo journalctl -u ollod -f -o cat
```
## Status of sinchronization:
```
ollod status 2>&1 | jq .SyncInfo
curl http://localhost:16657/status | jq .result.sync_info.catching_up
```
## Check Node ID:
```
curl localhost:16657/status | jq '.result.node_info.id'
```
## testnet-Faucet:
* Get verified
* Get Testnet Explorers role in #roles channel
* Join to [Discord](https://discord.gg/vQnbV34c) and navigate to: # testnetfaucet to request test tokens
```
!request YOUR_WALLET_ADDRESS
```
## Check your balance:
```
ollod q bank balances $(ollod keys show $OLLO_WALLET -a)
```
## Create validator:
```
ollod tx staking create-validator \
  --amount 2000000utollo \
  --pubkey  $(ollod tendermint show-validator) \
  --from $OLLO_WALLET \
  --moniker $OLLO_MONIKER \
  --chain-id $OLLO_CHAIN \
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
curl localhost:16657/status | jq
```
## Collect rewards:
```
ollod tx distribution withdraw-all-rewards \
 --from $OLLO_WALLET \
 --chain-id $OLLO_CHAIN
```
## Delegate tokens to your validator:
```
ollod tx staking delegate $(ollod keys show $OLLO_WALLET --bech val -a) <amontumpwr> \
 --from=$OLLO_WALLET \
 --chain-id $OLLO_CHAIN
```
## Unjail:
```
ollod tx slashing unjail \
 --from $OLLO_WALLET \
 --chain-id $OLLO_CHAIN
```
## Stop the node:
```
sudo systemctl stop ollod
```
## Delete node files and directories:
```
sudo systemctl stop ollod
sudo systemctl disable ollod
rm /etc/systemd/system/ollod.service
rm -Rvf $HOME/ollo
rm -Rvf $HOME/.ollo
```
## Official links:
[Discord](https://discord.gg/vQnbV34c)

[Official instruction](https://docs.ollo.zone/validators/running_a_node)

[Explorer](https://ollo.explorers.guru/validators)
