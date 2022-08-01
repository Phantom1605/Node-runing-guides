## Install dependencies:
```
cd $HOME
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils curl nano htop mc -y
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
```

## Clone git repository and install:
```
cd $HOME
git clone https://github.com/Stride-Labs/gaia.git
cd gaia
git checkout 5b47714dd5607993a1a91f2b06a6d92cbb504721
make build
cp $HOME/gaia/build/gaiad /usr/local/bin
```

## Add variables:
```
echo 'export GAIA_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export GAIA_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export GAIA_CHAIN="GAIA"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $GAIA_MONIKER
echo $GAIA_WALLET
echo $GAIA_CHAIN
```

## Init:
```
gaiad init $GAIA_MONIKER --chain-id $GAIA_CHAIN
```
## Recover or create new wallet:
* create new wallet:
```
gaiad keys add $GAIA_WALLET
```
* recover existing wallet:
```
gaiad keys add $GAIA_WALLET --recover
```
## Download genesis:
```
wget -qO $HOME/.gaia/config/genesis.json "https://raw.githubusercontent.com/Stride-Labs/testnet/main/poolparty/gaia/gaia_genesis.json"
```

## Unsafe restart all:
```
gaiad tendermint unsafe-reset-all --home ~/.gaiad
```

## Set seeds and peers:
```
SEEDS=""
PEERS="5b1bd3fb081c79b7bdc5c1fd0a3d90928437266a@78.107.234.44:36656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.gaia/config/config.toml
```
## Set minimum gas price:
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uatom\"/" $HOME/.gaia/config/app.toml
```
## Set custop ports:
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:26653\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:26652\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:6061\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:26651\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":26655\"%" $HOME/.gaia/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:1317\"%; s%^address = \":8080\"%address = \":8080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:9092\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:9093\"%" $HOME/.gaia/config/app.toml
```
## Config node:
```
gaiad config node tcp://localhost:26652
```

## Config pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.gaia/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.gaia/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.gaia/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.gaia/config/app.toml
```
## install service to run the node:
```
sudo tee /etc/systemd/system/gaiad.service > /dev/null <<EOF
[Unit]
Description=gaia
After=network-online.target

[Service]
User=$USER
ExecStart=$(which gaiad) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF


sudo systemctl daemon-reload
sudo systemctl enable gaiad
sudo systemctl restart gaiad
sudo journalctl -u gaiad -f -o cat
```
## Check your node logs:
```
sudo journalctl -u gaiad -f -o cat
```
## Status of sinchronization:
```
gaiad status 2>&1 | jq .SyncInfo
curl http://localhost:26652/status | jq .result.sync_info.catching_up
```
## Faucet:
Join to [Discord](http://stride.zone/discord) and navigate to:

* #token-faucet to request test tokens
```
$faucet-atom:<you gaia wallet address>
```

## Check your balance:
```
gaiad q bank balances $(gaiad keys show $GAIA_WALLET -a)
```
## Create validator:
```
gaiad tx staking create-validator \
  --amount=1000000uatom \
  --from $GAIA_WALLET \
  --commission-max-change-rate=0.01 \
  --commission-max-rate=0.2 \
  --commission-rate=0.08 \
  --min-self-delegation=1 \
  --details="" \
  --website="" \
  --identity=""\
  --pubkey=$(junod tendermint show-validator) \
  --moniker=$GAIA_MONIKR \
  --chain-id=$GAIA_CHAIN
```
## Check your node status:
```
curl localhost:26652/status
```
## Collect rewards:
```
gaiad tx distribution withdraw-all-rewards \
  --chain-id=$GAIA_CHAIN \
  --from $GAIA_WALLET
```

## Delegate tokens to your validator:
```
gaiad tx staking delegate gaiad keys show $GAIA_WALLET --bech val -a) 1000000uatom \
  --chain-id=$GAIA_CHAIN \
  --from=$GAIA_WALLET
```
## Unjail:
```
gaiad tx slashing unjail \
--chain-id $GAIA_CHAIN \ 
--from $GAIA_WALLET
```

## Stop the node:
```
sudo systemctl stop gaiad
```
## Delete node files and directories:
```
sudo systemctl stop gaiad
sudo systemctl disable gaiad
rm /etc/systemd/system/junod.service
rm -Rvf $HOME/gaia
rm -Rvf $HOME/.gaia
```
## Official links:

[Discord](http://stride.zone/discord)

[Explorer](https://poolparty.stride.zone/GAIA/staking)
