## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev curl build-essential git jq ncdu bsdmainutils mc htop -y
```
## Install Go:
```
wget -O go1.19.2.linux-amd64.tar.gz https://golang.org/dl/go1.19.1.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.2linux-amd64.tar.gz && rm go1.19.2linux-amd64.tar.gz

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
git clone https://github.com/NibiruChain/nibiru
cd nibiru
git checkout v0.19.2
nibid version version
cp $HOME/go/bin/nibid /usr/local/bin
```
## Add variables:
```
echo 'export NIBIRU_MONIKER="your node moniker"'>> $HOME/.bash_profile
echo 'export NIBIRU_WALLET="your wallet name"'>> $HOME/.bash_profile
echo 'export NIBIRU_CHAIN="nibiru-itn-1"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $NIBIRU_MONIKER
echo $NIBIRU_WALLET
echo $NIBIRU_CHAIN
```
## Init:
```
defundd init $NIBIRU_MONIKER --chain-id $NIBIRU_CHAIN
```
## Recover or create new wallet:
* create new wallet:
```
nibid keys add $NIBIRU_WALLET
```
* recover existing wallet:
```
nibid keys add $NIBIRU_WALLET --recover
```
## Dowload genesis:
```
curl -s https://rpc.itn-1.nibiru.fi/genesis | jq -r .result.genesis > $HOME/.nibid/config/genesis.json
```
## Set seeds:
```
sed -i -e "s|seeds =.*|seeds = "'$(curl -s https://networks.itn.nibiru.fi/$NETWORK_NIBIRU/seeds)'"/" $HOME/.nibid/config/config.toml
```
## Set custom ports:
```
DEFUND_PORT=34
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NIBIRU_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NIBIRU_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NIBIRU_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NIBIRU_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NIBIRU_PORT}660\"%" $HOME/.nibidd/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${NIBIRU_PORT}317\"%; s%^address = \":8080\"%address = \":${NIBIRU_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${NIBIRU_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NIBIRU_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${NIBIRU_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${NIBIRU_PORT}546\"%" $HOME/.nibidd/config/app.toml
```
## Config node:
```
nibid config node tcp://localhost:34657
```
## Config pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.nibid/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.nibid/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.nibid/config/app.toml
```
## Set minimum gas price:
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025unibi\"/" $HOME/.nibid/config/app.toml
```
## Unsefe reset all:
```
nibid tendermint unsafe-reset-all --home ~/.defund
```
## Create servise file:
```
sudo tee /etc/systemd/system/nibid.service > /dev/null <<EOF
[Unit]
Description=nibiru
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

sudo systemctl enable nibid
sudo systemctl daemon-nibid
sudo systemctl restart nibid
sudo systemctl status nibid
```
## Check your node logs:
```
sudo journalctl -u nibid -f -o cat
```
## Status of sinchronization:
```
defundd status 2>&1 | jq .SyncInfo
curl http://localhost:34657/status | jq .result.sync_info.catching_up
```
## Check Node ID:
```
curl localhost:34657/status | jq '.result.node_info.id'
```
## Faucet:
* You can go to their [application] (https://app.nibiru.fi/), connect your Kepler wallet and request tokens, or do it manually via the terminal.
```
FAUCET_URL="https://faucet.itn-1.nibiru.fi/"
curl -X POST -d '{"address": "'"$ADDR"'", "coins": ["11000000unibi","100000000unusd","100000000uusdt"]}' $FAUCET_URL
```
## Check your balance:
```
nibid q bank balances $(nibid keys show $NIBIRU_WALLET -a)
```
## Create validator:
```
nibid tx staking create-validator \
  --amount 10000000unibi \
  --pubkey  $(nibid tendermint show-validator) \
  --from $NIBIRU_WALLET \
  --moniker $NIBIRU_MONIKER \
  --chain-id $NIBIRU_CHAIN \
  --details="" \
  --website= "" \
  --identity="" \
  --min-self-delegation=1 \
  --commission-max-change-rate=0.1 \
  --commission-max-rate=0.2 \
  --commission-rate=0.1 \
  --gas-prices 0.025unibi
  ```
  ## Check your node status:
```
curl localhost:34657/status | jq
```
## Withdraw rewards:
```
nibid tx distribution withdraw-all-rewards \
 --from $NIBIRU_WALLET
 --chain-id=$NIBIRU_CHAIN
 --gas-prices 0.025unibi
```
## Withdraw validator commission:
```
nibid tx distribution withdraw-rewards $(nibid keys show $NIBIRU_WALLET --bech val -a) \
--chain-id $NIBIRU_CHAIN \
--from $NIBIRU_WALLET \
--gas-prices 0.025unibi \
--commission \
--yes
```
## Delegate tokens to your validator:
```
nibid tx staking delegate $(nibid keys show $DEFUND_WALLET --bech val -a) <amontunibi> \
 --chain-id=$NIBIRU_CHAIN
 --from=$NIBIRU_WALLET
 --gas-prices 0.025unibi
```
## Unjail:
```
nibid tx slashing unjail \
 --from $NIBIRU_WALLET \
 --chain-id=$NIBIRU_CHAIN \
--gas-prices 0.025unibi
```
## Stop the node:
```
sudo systemctl stop nibid
```
## Delete node files and directories:
```
sudo systemctl stop nibid
sudo systemctl disable nibid
rm /etc/systemd/system/defundd.service
rm -Rvf $HOME/nibid
rm -Rvf $HOME/.nibid
```
## Official links:

[Discord](https://discord.gg/nibiru)

[Explorer](https://explorer.kjnodes.com/nibiru-testnet/staking)

[Officcial instructions] (https://docs.nibiru.fi/)

[Officcial site] (https://nibiru.fi/)

[NIbiru application] (https://app.nibiru.fi/)
