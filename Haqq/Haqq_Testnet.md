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
git clone https://github.com/haqq-network/haqq && cd cd $HOME/haqq
git checkout v1.2.0
make install
haqqd version --long | head
```
## Add variables:
```
echo 'export HAQQ_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export HAQQ_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export HAQQ_CHAIN="haqq_54211-3"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $HAQQ_MONIKER
echo $HAQQ_WALLET
echo $HAQQ_CHAIN
```
## Init:
```
haqqd init $HAQQ_MONIKER --chain-id $HAQQ_CHAIN
```
## Recover or create new wallet:
* create new wallet:
```
haqqd keys add $HAQQ_WALLET
```
* recover existing wallet:
```
haqqd keys add $HAQQ_WALLET --recover
```
## Download genesis:
```
wget -qO $HOME/.haqqd/config/genesis.json "https://raw.githubusercontent.com/haqq-network/validators-contest/master/genesis.json"
```
## Unsafe restart all
```
haqqd tendermint unsafe-reset-all --home ~/.haqqd
```
## Set seeds and peers:
```
seeds="62bf004201a90ce00df6f69390378c3d90f6dd7e@seed2.testedge2.haqq.network:26656,23a1176c9911eac442d6d1bf15f92eeabb3981d5@seed1.testedge2.haqq.network:26656"
peers="b3ce1618585a9012c42e9a78bf4a5c1b4bad1123@65.21.170.3:33656,952b9d918037bc8f6d52756c111d0a30a456b3fe@213.239.217.52:29656,85301989752fe0ca934854aecc6379c1ccddf937@65.109.49.111:26556,d648d598c34e0e58ec759aa399fe4534021e8401@109.205.180.81:29956,f2c77f2169b753f93078de2b6b86bfa1ec4a6282@141.95.124.150:20116,eaa6d38517bbc32bdc487e894b6be9477fb9298f@78.107.234.44:45656,37513faac5f48bd043a1be122096c1ea1c973854@65.108.52.192:36656,d2764c55607aa9e8d4cee6e763d3d14e73b83168@66.94.119.47:26656,fc4311f0109d5aed5fcb8656fb6eab29c15d1cf6@65.109.53.53:26656,297bf784ea674e05d36af48e3a951de966f9aa40@65.109.34.133:36656,bc8c24e9d231faf55d4c6c8992a8b187cdd5c214@65.109.17.86:32656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.haqqd/config/config.toml
```
## Set minimum gas prices:
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0aISLM\"/" $HOME/.haqqd/config/app.toml
```
## Set custom ports:
```
EMPOWER_PORT=17
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${HAQQ_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${HAQQ_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${HAQQ_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${HAQQ_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${HAQQ_PORT}660\"%" $HOME/.haqq/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${HAQQ_PORT}317\"%; s%^address = \":8080\"%address = \":${HAQQ_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${HAQQ_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${HAQQ_PORT}091\"%" $HOME/.haqq/config/app.toml
```
## Config node:
```
haqqd config node tcp://localhost:17657
```
## Configure pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.haqq/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.haqqd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.haqqd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.haqqd/config/app.toml
```
## Disable indexing:
```
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.haqqd/config/config.toml
```
## Install service file to run the node:
```
sudo tee /etc/systemd/system/haqqd.service > /dev/null <<EOF
[Unit]
Description=haqq
After=network-online.target

[Service]
User=$USER
ExecStart=$(which haqqd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable haqqd
sudo systemctl daemon-reload
sudo systemctl restart haqqd
sudo systemctl status haqqd
```
## Check your node logs:
```
sudo journalctl -u hqqd -f -o cat
```
## Status of sinchronization:
```
haqqd status 2>&1 | jq .SyncInfo
curl http://localhost:15657/status | jq .result.sync_info.catching_up
```
## Check Node ID:
```
curl localhost:15657/status | jq '.result.node_info.id'
```
## Faucet:
To create a validator, first you need to top up your wallet with testnet tokens:
```
https://testedge2.haqq.network/
```
## Check your balance:
```
haqqd q bank balances $(haqqd keys show $HAQQ_WALLET -a)
```
## Create validator:
```
haqqd tx staking create-validator \
  --amount 100000000aISLM \
  --pubkey  $(haqqd tendermint show-validator) \
  --from $HAQQ_WALLET \
  --moniker $HAQQ_MONIKER \
  --chain-id $HAQQ_CHAIN \
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
haqqd tx distribution withdraw-all-rewards \
 --from $HAQQ_WALLET
 --chain-id=$HAQQ_CHAIN
 --gas=auto
```
## Withdraw validator commission:
```
haqqd tx distribution withdraw-rewards $(haqqd keys show $HAQQ_WALLET --bech val -a) \
--chain-id $HAQQ_CHAIN \
--from $HAQQ_WALLET \
--commission \
--yes
```
## Delegate tokens to your validator:
```
haqqd tx staking delegate $(haqqd keys show $EMPOWER_WALLET --bech val -a) <amontaISLM> \
 --chain-id=$HAQQ_CHAIN
 --from=$HAQQ_WALLET
 --gas=auto
```
## Unjail:
```
empowerd tx slashing unjail \
 --from $HAQQ_WALLET \
 --chain-id=$HAQQ_CHAIN \
 --gas=auto
```
## Stop the node:
```
sudo systemctl stop empowerd
```
## Delete node files and directories:
```
sudo systemctl stop haqqd
sudo systemctl disable haqqd
rm /etc/systemd/system/haqqd.service
rm -Rvf $HOME/haqq
rm -Rvf $HOME/.haqqd
```
## Official links:

[Discord](https://discord.gg/S4XbyHzy)

[Github](https://github.com/haqq-network/validators-contest)

[HAQQ faucet](https://testedge2.haqq.network/)

[Crew3](https://haqq-val-contest.crew3.xyz/questboard)

[Explorer](https://exploreralex845.click/haqq/staking)
