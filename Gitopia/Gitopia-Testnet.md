## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt-get install nano mc git gcc g++ make curl yarn -y
```

## install Go:
```
wget -O go1.19.2.linux-amd64.tar.gz https://golang.org/dl/go1.19.2.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.2.linux-amd64.tar.gz && rm go1.19.2.linux-amd64.tar.gz

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
curl https://get.gitopia.com | bash
git clone -b v1.2.0 gitopia://gitopia/gitopia
cd gitopia && make install
gitopiad version
```
## Add variables:
```
echo 'export GITOPIA_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export GITOPIA_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export GITOPIA_CHAIN="gitopia-janus-testnet-2
"' >> $HOME/.bash_profile
. $HOME/.bash_profile

#let's check
echo $GITOPIA_MONIKER
echo $GITOPIA_WALLET
echo $GITOPIA_CHAIN
```
## Init:
```
gitopiad init $GITOPIA_MONIKER --chain-id $GITOPIA_CHAIN
```
## Recover or create new wallet:
* create new wallet:
```
gitopiad keys add $GITOPIA_WALLET
```
* recover existing wallet:
```
gitopiad keys add $GITOPIA_WALLET --recover
```
## Minimum gas prices:
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \""0.001utlore"\"/" $HOME/.~/.gitopia/config/app.toml
```

## Download genesis:
```
wget https://server.gitopia.com/raw/gitopia/testnets/master/gitopia-janus-testnet-2/genesis.json.gz
gunzip genesis.json.gz
mv genesis.json $HOME/.gitopia/config/genesis.json
```
## Unsafe restart all
```
gitopiad tendermint unsafe-reset-all --home ~/.gitopia
```
## Set seeds and peers:
```
SEEDS="399d4e19186577b04c23296c4f7ecc53e61080cb@seed.gitopia.com:26656"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.gitopia/config/config.toml
```
## Set minimum gas prices:
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0utlore\"/" $HOME/.gitopia/config/app.toml
```
## Set custom ports:
```
GITOPIA_PORT=23
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${GITOPIA_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${GITOPIA_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${GITOPIA_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${DEFUND_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${GITOPIA_PORT}660\"%" $HOME/.gitopia/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${GITOPIA_PORT}317\"%; s%^address = \":8080\"%address = \":${GITOPIA_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${GITOPIA_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${GITOPIA_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${GITOPIA_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${GITOPIA_PORT}546\"%" $HOME/.gitopia/config/app.toml
```
## Config node:
```
gitopiad config node tcp://localhost:23657
```
## Install service to run the node:
```
sudo tee <<EOF >/dev/null /etc/systemd/system/gitopiad.service
[Unit]
Description=Gitopia Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which gitopiad) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable gitopiad
sudo systemctl restart gitopiad
```

## Check your node logs:
```
journalctl -u gitopia -f
```

## Status of sinchronization:
```
gitopiad status 2>&1 | jq .SyncInfo
```
## Now insert the mnemonic that you saved into the Keplr wallet.
* We go to [gitopia website](https://gitopia.com/home), subtract Keplr and request tokens for it.

## Create validator:
```
gitopiad tx staking create-validator \
--amount=5000000utlore \
--pubkey=$(gitopiad tendermint show-validator) \
--from=$GITOPIA_WALLET \
--moniker=$GITOPIA_MONIKER \
--chain-id=$GITOPIA_CHAIN \
--details="" \
--website="" \
--identity="" \
--commission-rate=0.6 \
--commission-max-rate=0.2 \
--commission-max-change-rate=0.1 \
--min-self-delegation=1 \
```
## Check your node status:
```
curl localhost:26657/status | jq
```
## Withdraw rewards:
```
gitopiad tx distribution withdraw-all-rewards \
--from $GITOPIA_WALLET
--chain-id=$GITOPIA_CHAIN
--gas=auto
```
## Withdraw validator commission:
```
gitopiad tx distribution withdraw-rewards $(gitopiad keys show $GITOPIA_WALLET --bech val -a) \
--chain-id $GITOPIA_CHAIN \
--from $GITOPIA_WALLET \
--commission \
--yes
```
## Delegate tokens to your validator:
```
gitopiad tx staking delegate $(gitopiad keys show $GITOPIA_WALLET --bech val -a) <amontutlore> \
--chain-id=$GITOPIA_CHAIN
--from=$GITOPIA_WALLET
--gas=auto
```
## Unjail:
```
gitopiad tx slashing unjail \
--from $GITOPIA_WALLET \
--chain-id=$GITOPIA_CHAIN \
--gas=auto
```
## Delete node files and directories:
```
sudo systemctl stop gitopiad
sudo systemctl disable gitopiad
rm /etc/systemd/system/gitopiad.service
rm -Rvf $HOME/gitopia
rm -Rvf $HOME/.gitopia
```
## Official links:

[Discord](https://discord.gg/JyfJN477)

[Official instructions](https://docs.gitopia.com/validator-overview)

[Explorer](https://explorer.gitopia.com/validators)
