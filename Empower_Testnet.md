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
git clone https://github.com/empowerchain/empowerchain
cd empowerchain/chain
make install
empowerd version --long | head
```
## Add variables:
```
echo 'export EMPOWER_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export EMPOWER_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export EMPOWER_CHAIN="altruistic-1"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $EMPOWER_MONIKER
echo $EMPOWER_WALLET
echo $EMPOWER_CHAIN
```
## Init:
```
empowerd init $EMPOWER_MONIKER --chain-id $EMPOWER_CHAIN
```
## Recover or create new wallet:
* create new wallet:
```
empowerd keys add $EMPOWER_WALLET
```
* recover existing wallet:
```
empowerd keys add $EMPOWER_WALLET --recover
```
## Download genesis:
```
wget -qO $HOME/.empowerchain/config/genesis.json "https://raw.githubusercontent.com/empowerchain/empowerchain/main/testnets/altruistic-1/genesis.json"
```
## Unsafe restart all:
```
empowerd tendermint unsafe-reset-all --home ~/.empowerchain
```
## Set seeds and peers:
```
peers="9de92b545638f6baaa7d6d5109a1f7148f093db3@65.108.77.106:26656,4fd5e497563b2e09cfe6f857fb35bdae76c12582@65.108.206.56:26656,fe32c17373fbaa36d9fd86bc1146bfa125bb4f58@5.9.147.185:26656,220fb60b083bc4d443ce2a7a5363f4813dd4aef4@116.202.236.115:26656,225ad85c594d03942a026b90f4dab43f90230ea0@88.99.3.158:26656,2a2932e780a681ddf980594f7eacf5a33081edaf@192.168.147.43:26656,333de3fc2eba7eead24e0c5f53d665662b2ba001@10.132.0.11:26656,4a38efbae54fd1357329bd583186a68ccd6d85f9@94.130.212.252:26656,52450b21f346a4cf76334374c9d8012b2867b842@167.172.246.201:26656,56d05d4ae0e1440ad7c68e52cc841c424d59badd@192.168.1.46:26656,6a675d4f66bfe049321c3861bcfd19bd09fefbde@195.3.223.204:26656,1069820cdd9f5332503166b60dc686703b2dccc5@138.201.141.76:26656,277ff448eec6ec7fa665f68bdb1c9cb1a52ff597@159.69.110.238:26656,3335c9458105cf65546db0fb51b66f751eeb4906@5.189.129.30:26656,bfb56f4cb8361c49a2ac107251f92c0ea5a1c251@192.168.1.177:26656,edc9aa0bbf1fcd7433fcc3650e3f50ab0becc0b5@65.21.170.3:26656,d582bcd8a8f0a20c551098571727726bc75bae74@213.239.217.52:26656,eb182533a12d75fbae1ec32ef1f8fc6b6dd06601@65.109.28.219:26656,b22f0708c6f393bf79acc0a6ca23643fe7d58391@65.21.91.50:26656,e8f6d75ab37bf4f08c018f306416df1e138fd21c@95.217.135.41:26656,ed83872f2781b2bdb282fc2fd790527bcb6ffe9f@192.168.3.17:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.empowerchain/config/config.toml
seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.empowerchain/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $HOME/.empowerchain/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $HOME/.empowerchain/config/config.toml
```
## Set custom ports:
```
EMPOWER_PORT=15
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${EMPOWER_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${EMPOWER_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${EMPOWER_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${EMPOWER_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${EMPOWER_PORT}660\"%" $HOME/.empowerchain/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${EMPOWER_PORT}317\"%; s%^address = \":8080\"%address = \":${EMPOWER_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${EMPOWER_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${EMPOWER_PORT}091\"%" $HOME/.empowerchain/config/app.toml
```
## Config node:
```
empowerd config node tcp://localhost:$(EMPOWER_PORT)657
```
## Set minimum gas prices:
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0umpwr\"/" ~/.empowerchain/config/app.toml
```
## Configure pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.empowerchain/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.empowerchain/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.empowerchain/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.empowerchain/config/app.toml
```
## Disable indexing:
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.empowerchain/config/config.toml
```
## Install service file to run the node:
```
sudo tee /etc/systemd/system/empowerd.service > /dev/null <<EOF
[Unit]
Description=Empower
After=network-online.target

[Service]
User=$USER
ExecStart=$(which empowerd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable empowerd
sudo systemctl daemon-empowerd
sudo systemctl restart empowerd
sudo systemctl status empowerd
```
## Check your node logs:
```
sudo journalctl -u empowerd -f -o cat
```
## Status of sinchronization:
```
strided status 2>&1 | jq .SyncInfo
curl http://localhost:13657/status | jq .result.sync_info.catching_up
```
## Check Node ID:
```
curl localhost:13657/status | jq '.result.node_info.id'
```
## Create validator:
```
empowerd tx staking create-validator \
  --amount 1000000umpwr \
  --pubkey  $(empowerd tendermint show-validator) \
  --from $EMPOWER_WALLET \
  --moniker $EMPOWER_MONIKER \
  --chain-id $EMPOWER_CHAIN \
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
## Collect rewards:
```
rebus tx distribution withdraw-all-rewards \
 --chain-id=$REBUS_CHAIN \
 --from $REBUS_WALLET
```
## Delegate tokens to your validator:
```
empowerd tx staking delegate $(empowerd keys show $EMPOWER_WALLET --bech val -a) <amontumpwr> \
 --chain-id=$EMPOWER_CHAIN \
 --from=$EMPOWER_WALLET
```
## Unjail:
```
rebusd tx slashing unjail \
 --chain-id $EMPOWER_CHAIN \
 --from $EMPOWER_WALLET 
```
## Stop the node:
```
sudo systemctl stop empowerd
```
## Delete node files and directories:
```
sudo systemctl stop empowerd
sudo systemctl disable empowerd
rm /etc/systemd/system/empowerd.service
rm -Rvf $HOME/empowerchain
rm -Rvf $HOME/.empowerchain
```
## fficial links:
[Github](https://github.com/empowerchain)

[Website](https://www.empower.eco/)

[Explorer](https://testnet.ping.pub/empower/staking)
