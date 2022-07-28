## Install dependencies:
```
cd $HOME
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils curl nano htop mc -y
```

## Install Go:
```
wget -O go1.18.2.linux-amd64.tar.gz https://go.dev/dl/go1.18.2.inux-amd64.tar.gz
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

## Clone git repository and install:
```
cd $HOME
git clone https://github.com/CosmosContracts/juno
cd juno
git checkout v7.0.0-beta.2
make build && make install
cp $HOME/go/bin/junod /usr/local/bin
```

## Add variables:
```
echo 'export JUNO_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export JUNO_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export JUNO_CHAIN="uni-3"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $JUNO_MONIKER
echo $JUNO_WALLET
echo $JUNO_CHAIN
```

## Init:
```
junod init $JUNO_MONIKER --chain-id $JUNO_CHAIN
```
## Generate keys:
```
junod keys add $JUNO_WALLET
```

## Download genesis and addrbook:
```
wget -qO $HOME/.juno/config/genesis.json "https://raw.githubusercontent.com/CosmosContracts/testnets/main/uni-3/genesis.json"
```

## Unsafe restart all:
```
junod tendermint unsafe-reset-all --home ~/.junod
```

## Set seeds and peers:
```
SEEDS=""
PEERS="26709b3d89548a865ccfd2efac34ef3e9a5b2bc4@135.181.59.162:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.juno/config/config.toml
```
## Set minimum gas price:
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ujunox\"/" $HOME/.juno/config/app.toml
```
## Set custop port:
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:26653\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:26652\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:6061\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:26651\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":26655\"%" $HOME/.juno/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:1317\"%; s%^address = \":8080\"%address = \":8080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:9092\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:9093\"%" $HOME/.juno/config/app.toml
```
## Config app:
```
junod config node tcp://localhost:26652
```

## Config pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.juno/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.juno/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.juno/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.juno/config/app.toml
```
## install service to run the node:
```
sudo tee /etc/systemd/system/junod.service > /dev/null <<EOF
[Unit]
Description=juno
After=network-online.target

[Service]
User=$USER
ExecStart=$(which junod) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF


sudo systemctl daemon-reload
sudo systemctl enable junod
sudo systemctl restart junod
sudo journalctl -u junod -f -o cat
```
## Check your node logs:
```
sudo journalctl -u junod -f -o cat
```
## Status of sinchronization:
```
junod status 2>&1 | jq .SyncInfo
curl http://localhost:26652/status | jq .result.sync_info.catching_up
```
## Faucet:
Join to [Discord](https://discord.gg/xQ8eNp7u)
and navigate to:
* #faucet channel to request test tokens
```
$request <your juno wallet address>
```

## Check your balance:
```
junod q bank balances $(junod keys show $JUNO_WALLET -a)
```
## Create validator:
```
junod tx staking create-validator \
  --amount=10000000ujunox \
  --from $JUNO_WALLET \
  --commission-max-change-rate=0.01 \
  --commission-max-rate=0.2 \
  --commission-rate=0.08 \
  --min-self-delegation=1 \
  --details="" \
  --website="" \
  --identity=""\
  --pubkey=$(junod tendermint show-validator) \
  --moniker=$JUNO_MONIKR \
  --chain-id=$JUNO_CHAIN
```
## Check your node status:
```
curl localhost:26657/status
```
## Collect rewards:
```
junod tx distribution withdraw-all-rewards \
  --chain-id=$JUNO_CHAIN \
  --from $JUNO_WALLET
```

## Delegate tokens to your validator:
```
junod tx staking delegate $(junod keys show $JUNO_WALLET --bech val -a) 10000000ujunox \
  --chain-id=$JUNO_CHAIN \
  --from=$JUNO_WALLET
```
## Unjail:
```
junod tx slashing unjail \
  --chain-id $JUNO_CHAIN \ 
  --from $JUNO_WALLET
```

## Stop the node:
```
sudo systemctl stop junod
```
## Delete node files and directories:
```
sudo systemctl stop junod
sudo systemctl disable junodd
rm /etc/systemd/system/junod.service
rm -Rvf $HOME/juno
rm -Rvf $HOME/.juno
```
Official links:

[Discord](https://discord.gg/xQ8eNp7u)

[Explorer](https://testnet.juno.explorers.guru/validators)
