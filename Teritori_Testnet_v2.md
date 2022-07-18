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
git clone https://github.com/TERITORI/teritori-chain
cd teritori-chain
git checkout teritori-testnet-v2
make install
cp $HOME/go/bin/teritorid /usr/local/bin
```

## Add variables:
```
echo 'export TERITORI_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export TERITORI_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export TERITORI_CHAIN="teritori-testnet-v2"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $TERITORI_MONIKER
echo $TERITORI_WALLET
echo $TERITORI_CHAIN
```

## Init:
```
seid init $TERITORI_MONIKER --chain-id $TERITORI_CHAIN
```
## Generate keys:
```
seid keys add $TERITORI_WALLET
```

## Download genesis and adrrbook:
```
wget -qO $HOME/.teritorid/config/genesis.json "https://raw.githubusercontent.com/TERITORI/teritori-chain/main/testnet/teritori-testnet-v2/genesis.json"
wget -qO $HOME/.teritorid/config/addrbook.json "https://raw.githubusercontent.com/StakeTake/guidecosmos/main/teritori/teritori-testnet-v2/addrbook.json"
```

## Unsafe restart all:
```
teritorid tendermint unsafe-reset-all --home ~/.teritorid
```

## Set minimum gas prices:
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0utori\"/" $HOME/.teritorid/config/app.toml
```
## Config pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.teritorid/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.teritorid/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.teritorid/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.teritorid/config/app.toml
```
## install service to run the node:
```
sudo tee /etc/systemd/system/teritorid.service > /dev/null <<EOF
[Unit]
Description=teritori
After=network-online.target

[Service]
User=$USER
ExecStart=$(which teritorid) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable teritorid
sudo systemctl restart teritorid
```
## Check your node logs:
```
sudo journalctl -u teritorid -f -o cat
```
## Status of sinchronization:
```
teritorid status 2>&1 | jq .SyncInfo
curl http://localhost:26657/status | jq .result.sync_info.catching_up
```
## Faucet:
Go to Discord [faucet channel](https://discord.com/channels/972545424357474334/991387449295122492)

## Сheck your balance:
```
teritorid q bank balances $(teritorid keys show $TERITORI_WALLET -a)
```
## Create validator:
```
teritorid tx staking create-validator \
  --amount=1000000utori \
  --from $TERITORI_WALLET \
  --commission-max-change-rate=0.01 \
  --commission-max-rate=0.2 \
  --commission-rate=0.08 \
  --min-self-delegation=1 \
  --details="" \
  --website="" \
  --identity=""\
  --pubkey=$(teritorid tendermint show-validator) \
  --moniker=$TERITORI_MONIKR \
  --chain-id=$TERITORI_CHAIN_ID
```
## Check your node status:
```
curl localhost:26657/status
```
## Collect rewards:
```
teritorid tx distribution withdraw-all-rewards \
  --chain-id=$TERITORI_CHAIN \
  --from $TERITORI_WALLET \
  --gas auto \
```

## Delegate tokens to your validator:
```
teritorid tx staking delegate $(teritorid keys show $TERITORI_WALLET --bech val -a) 10000000utori \
  --chain-id=$TERITORICHAIN \
  --from=$TERITORI_WALLET \
  --gas auto \
```
## Voting:
```
teritorid tx gov vote 1 yes --from $TERITORI_WALLET --chain-id=$TERITORI_CHAIN
```

## Unjail:
```
teritorid tx slashing unjail \
--chain-id $TERITORI_CHAIN \ 
--from $TERITORI_WALLET \ 
--gas=auto \ 
```

## Stop the node:
```
sudo systemctl stop teritorid
```
## Delete node files and directories:
```
sudo systemctl stop teritorid
sudo systemctl disable teritorid
rm /etc/systemd/system/seid.service
rm -Rvf $HOME/teritori
rm -Rvf $HOME/.teritorid
```

## Official links:

[Discord](https://discord.gg/QCMR9WQ7)

[Official docs](https://github.com/TERITORI/teritori-chain/tree/main/testnet/teritori-testnet-v2)

[Github](https://github.com/TERITORI/teritori-chain)

[Explorer](https://teritori.explorers.guru/validators)
