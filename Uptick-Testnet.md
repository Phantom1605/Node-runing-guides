## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils -y
```

## Install Go:
```
wget -O go1.18.1.linux-amd64.tar.gz https://golang.org/dl/go1.18.1.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.1.linux-amd64.tar.gz && rm go1.18.1.linux-amd64.tar.gz

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
git clone https://github.com/UptickNetwork/uptick.git
cd uptick
git checkout v0.2.0
```
## Install:
```
make install
cp $HOME/go/bin/uptickd /usr/local/bin
```
## Verify installation:
Verify that everything is OK.
```
uptickd version
```
## Add variables:
```
echo 'export NODE_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export YOUR_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export CHAIN_ID="uptick_7776-1"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $NODE_MONIKER
echo $YOUR_WALLET
echo $CHAIN_ID
```
## Init:
```
uptickd init $NODE_MONIKER --chain-id $CHAIN_ID
```
## Generate keys:
```
uptickd keys add $YOUR_WALLET
```
## Download genesis:
```
curl https://raw.githubusercontent.com/UptickNetwork/uptick-testnet/main/uptick_7776-1/genesis.json > ~/.uptickd/config/genesis.json
```
## Check genesis:
```
sha256sum ~/.uptickd/config/genesis.json
```

## Unsafe restart all:
```
uptickd tendermint unsafe-reset-all --home ~/.uptickd
```
## Prunning:
```
pruning="custom" && \
pruning_keep_recent="100" && \
pruning_keep_every="0" && \
pruning_interval="50" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.uptickd/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.uptickd/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.uptickd/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.uptickd/config/app.toml
```
## Configure your node:
```
Set minimum gas price:
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025auptick\"/;" ~/.uptickd/config/app.toml

PEERS=`curl -sL https://raw.githubusercontent.com/UptickNetwork/uptick-testnet/main/uptick_7776-1/peers.txt | sort -R | head -n 10 | awk '{print $1}' | paste -s -d, -`
echo $PEERS
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.uptickd/config/config.toml

SEEDS=`curl -sL https://raw.githubusercontent.com/UptickNetwork/uptick-testnet/main/uptick_7776-1/seeds.txt | awk '{print $1}' | paste -s -d, -`
echo $SEEDS
sed -i.bak -e "s/^seeds =.*/seeds = \"$SEEDS\"/" ~/.uptickd/config/config.toml
```
 ## install service to run the node:
```
sudo tee /etc/systemd/system/uptickd.service > /dev/null <<EOF
[Unit]
Description=uptick
After=network-online.target

[Service]
User=$USER
ExecStart=$(which uptickd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable uptickd
sudo systemctl restart uptickd
```

## Check your node logs:
```
journalctl -u uptickd -f
```

## Status of sinchronization:
```
uptickd status 2>&1 | jq .SyncInfo
curl http://localhost:26657/status | jq .result.sync_info.catching_up
```
## Faucet: [Discord](https://discord.gg/eStaNHZbm4)

## Сheck your balance:
```
cland q bank balances $(uptickd keys show $YOUR_WALLET -a)
```
## Create validator:
```
uptickd tx staking create-validator \
  --amount 1000000auptick \
  --commission-max-change-rate="0.10" \
  --commission-max-rate="0.20" \
  --commission-rate="0.10" \
  --min-self-delegation="1000000" \
  --details "" \
  --website=""\
  --identity= ""\
  --pubkey=$(uptickd tendermint show-validator) \
  --moniker=$NODE_MONIKER \
  --chain-id=$CHAIN_ID \
  --gas="auto" \
  --gas-prices="0.025auptick" \
  --from=$YOUR_WALLET
```
## Edit validator:
```
uptickd tx staking edit-validator
  --moniker=$NODE_MONIKER \
  --website="Your website" \
  --identity="Your identety" \
  --details="" \
  --chain-id=$CHAIN_ID \
  --gas="auto" \
  --gas-prices="0.025auptick" \
  --from=$YOUR_WALLET \
  --commission-rate="0.10"
  ```

## Check your node status:
```
curl localhost:26657/status
```
## Collect rewards:
```
cland tx distribution withdraw-all-rewards \
 --chain-id=$CHAIN_ID \
 --from $YOUR_WALLET \
 --gas auto \
 --gas-prices=0,025auptick
```

## Delegate tokens to your validator:
```
uptickd tx staking delegate $(uptick keys show $YOUR_WALLET --bech val -a) <amountauptick> \
--chain-id=$CHAIN_ID \
--from=$YOUR_WALLET \
--gas auto \
--gas-prices=0,025auptick
```

## Unjail:
```
uptickd tx slashing unjail \
--chain-id $CHAIN_ID \ 
--from $YOUR_TEST_WALLET \ 
--gas=auto \ 
--gas-prices=0,025auptick
```

## Stop the node:
```
sudo systemctl stop uptickd
```
## Delete node files and directories:
```
sudo systemctl stop uptickd
sudo systemctl disable uptickd
rm /etc/systemd/system/uptickd.service
rm -Rvf $HOME/uptick
rm -Rvf $HOME/.uptick
```

## Official links: 

[Official documents](https://docs.uptick.network/testnet/join.html)

[Discord](https://discord.gg/eStaNHZbm4)

[Github](https://github.com/UptickNetwork/uptick)

[Explorer](https://explorer.testnet.uptick.network/)


