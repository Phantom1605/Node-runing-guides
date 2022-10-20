## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils -y
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

. $HOME/.bash_profile
cp /usr/local/go/bin/go /usr/bin
go version
```

## Clone git repository and install?:
```
git clone https://github.com/UptickNetwork/uptick.git
cd uptick
git checkout vv0.2.2
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
echo 'export UPTICK_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export UPTICK_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export UPTICK_CHAIN="uptick_7000-1"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $UPTICK_MONIKER
echo $UPTICK_WALLET
echo $UPTICK_CHAIN
```
## Init:
```
uptickd init $UPTICK_MONIKER --chain-id $UPTICK_CHAIN
```
## Generate keys:
```
uptickd keys add $UPTICK_WALLET
```
## Download genesis:
```
curl https://raw.githubusercontent.com/UptickNetwork/uptick-testnet/main/uptick_7000-1/genesis.json > ~/.uptickd/config/genesis.json

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
#Set minimum gas price:
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025auptick\"/;" ~/.uptickd/config/app.toml

#Set custom ports:
UPTICK_PORT=18
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${HAQQ_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${HAQQ_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${HAQQ_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${HAQQ_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${HAQQ_PORT}660\"%" $HOME/.uptickd/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${HAQQ_PORT}317\"%; s%^address = \":8080\"%address = \":${HAQQ_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${HAQQ_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${HAQQ_PORT}091\"%" $HOME/.uptickd/config/app.toml

#Config node:
uptickdd config node tcp://localhost:18657

#Add peers:
PEERS=`curl -sL https://raw.githubusercontent.com/UptickNetwork/uptick-testnet/main/uptick_7000-1/peers.txt | sort -R | head -n 10 | awk '{print $1}' | paste -s -d, -`
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.uptickd/config/config.toml

#Add seeds:
SEEDS=`curl -sL https://raw.githubusercontent.com/UptickNetwork/uptick-testnet/main/uptick_7000-1/seeds.txt | awk '{print $1}' | paste -s -d, -`
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
## Faucet:
Join to [Discord](https://discord.gg/eStaNHZbm4) and navigate to:
* #faucet to request test tokens
```
$faucet <YOUR_WALLET_ADDRESS>
```
## Сheck your balance:
```
cland q bank balances $(uptickd keys show $YOUR_WALLET -a)
```
## Create validator:
```
uptickd tx staking create-validator \
 --amount 5000000000000000000auptick \
 --from=$UPTICK_WALLET
 --moniker=$UPTICK_MONIKER \
 --chain-id=$UPTICK_CHAIN \
 --pubkey=$(uptickd tendermint show-validator) \
 --commission-max-change-rate="0.10" \
 --commission-max-rate="0.20" \
 --commission-rate="0.07" \
 --min-self-delegation="1000000" \
 --details="" \
 --website="" \
 --identity="" \
 --gas="auto"

```
## Edit validator:
```
uptickd tx staking edit-validator
 --from=$UPTICK_WALLET \
 --moniker=$UPTICK_MONIKER \
 --chain-id=$UPTICK_CHAIN \
 --website="Your website" \
 --identity="Your identety" \
 --details="" \
 --gas="auto"
 --commission-rate="0.06"
  ```

## Check your node status:
```
curl localhost:26657/status
```
## Collect rewards:
```
uptickd tx distribution withdraw-all-rewards \
 --chain-id=$UPTICK_CHAIN \
 --from $UPTICK_WALLET \
 --gas auto \
 --gas-prices=0,025auptick
```

## Delegate tokens to your validator:
```
uptickd tx staking delegate $(uptick keys show $UPTICK_WALLET --bech val -a) <amountauptick> \
 --chain-id=$UPTICK_CHAIN \
 --from=$UPTICK_WALLET \
 --gas auto
```

## Unjail:
```
uptickd tx slashing unjail \
 --chain-id $UPTICK_CHAIN \ 
 --from $UPTICK_WALLET \ 
 --gas=auto
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
rm -Rvf $HOME/.uptickd
```
## Official links;
[Official documents](https://docs.uptick.network/testnet/join.html)

[Discord](https://discord.gg/eStaNHZbm4)

[Github](https://github.com/UptickNetwork/uptick)

[Explorer](https://explorer.testnet.uptick.network/)
