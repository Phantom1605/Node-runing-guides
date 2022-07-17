## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils htop -y < "/dev/null" -y
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

## Clone git repository:
```
cd $HOME
curl https://get.ignite.com/DecentralCardGame/Cardchain@latest! | sudo bash
```
## Add variables:
```
echo 'export CARDCHAIN_MONIKER="Your moniker"'>> $HOME/.bash_profile
echo 'export CARDCHAIN_WALLET="Your wallet name"'>> $HOME/.bash_profile
echo 'export CARDCHAIN_CHAIN="Cardchain"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $CARDCHAIN_MONIKER
echo $CARDCHAIN_WALLET
echo $CARDCHAIN_CHAIN
```
## Generate keys:
```
сardchain keys add $CARDCHAIN_WALLET
```
## Init:
```
Cardchain init $CARDCHAIN_MONIKER --chain-id $CARDCHAIN_CHAIN
```
## Generate keys:
```
сardchain keys add $CARDCHAIN_WALLET
```
## Add wallet and valoper address into system variables:
```
CARDCHAIN_WALLET_ADDRESS=$(Cardchain keys show $CARDCHAIN_WALLET -a)
CARDCHAIN_VALOPER_ADDRESS=$(Cardchain keys show $CARDCHAIN_WALLET --bech val -a)
echo 'export CARDCHAIN_WALLET_ADDRESS='${CARDCHAIN_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export CARDCHAIN_VALOPER_ADDRESS='${CARDCHAIN_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```
## Download genesis:
```
wget -qO $HOME/.Cardchain/config/genesis.json "https://raw.githubusercontent.com/DecentralCardGame/Testnet1/main/genesis.json"
```
## Set seeds and peers:
```
SEEDS=""
PEERS="cd1c88e7829a940fc6332c925943fb0e45588121@138.201.139.175:21106,a9c56a9479bbdb8aa7bfb93bd85907bd4f4a4cca@135.181.154.42:26656,407fd08d831eaec4be840bf762740a72c5c48ea6@159.69.11.174:36656,a506820ea90c5b0ddb9005ef720a121e9f6bbaeb@45.136.28.158:26658,8b376446ae31162449c9749390830b05420bdf55@95.216.223.244:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.Cardchain/config/config.toml
```
## Configure pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.Cardchain/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.Cardchain/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.Cardchain/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.Cardchain/config/app.toml
```
## Set minimum gas price:
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ubpf\"/" $HOME/.Cardchain/config/app.toml
```
## Unsafe reset all:
```
Cardchain unsafe-reset-all --home $HOME/.Cardchain
```
## Install service to run the node:
```
sudo tee /etc/systemd/system/Cardchain.service > /dev/null <<EOF
[Unit]
Description=Cardchain
After=network-online.target

[Service]
User=$USER
ExecStart=$(which Cardchain) start --home $HOME/.Cardchain
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable Cardchain
sudo systemctl restart Cardchain
sudo journalctl -u Cardchain -f -o cat
```
## Check your node logs:
```
journalctl -u Cardchaind -f --output cat
```
## Status of sinchronization:
```
Cardchain status 2>&1 | jq .SyncInfo

curl http://localhost:26657/status | jq .result.sync_info.catching_up
```
## Check Node ID:
```
curl localhost:26657/status | jq '.result.node_info.id'
```
## Faucet:
```
curl -X POST https://cardchain.crowdcontrol.network/faucet/ -d "{\"address\": \"$CARDCHAIN_WALLET_ADDRESS\"}"
```
## Check your balance:
```
Cardchain q bank balances $(cardchain keys show $CARDCHAIN_WALLET -a)
```
## Create validator:
```
Cardchain tx staking create-validator \
 --amount=1000000ubpf \
 --pubkey=$(Cardchain tendermint show-validator) \
 --from=$CARDCHAIN_WALLET \
 --moniker=$CARDCHAIN_MONIKER \
 --chain-id=$CARDCHAIN_CHAIN \
 --website="" \
 --identity="" \
 --min-self-delegation=1 \
 --commission-rate=0.08 \
 --commission-max-rate=0.2 \
 --commission-max-change-rate=0.01
```
## Check your node status:
```
curl localhost:26657/status
```
## Collect rewards:
```
cardchain tx distribution withdraw-all-rewards \
 --chain-id=$CARDCHAIN_CHAIN \
 --from $CARDCHAIN_WALLET
```
## Delegate tokens to your validator:
```
cardchain tx staking delegate $(Cardchaind keys show $CARDCHAIN_WALLET --bech val -a) 10000000ubpf \
 --chain-id=$CARDCHAIN_CHAIN \
 --from=$CARDCHAIN_WALLET
```
## Unjail:
```
cardchain tx slashing unjail \
 --chain-id $CARDCHAIN_CHAIN \ 
 --from $CARDCHAIN_WALLET
```
## Voting:
```
Cardchain tx gov vote 1 yes --from $CARDCHAIN_WALLET --chain-id=$CARDCHAIN_CHAIN
```
## Stop the node:
```
sudo systemctl stop Cardchaind
```
## Delete node files and directories:
```
sudo systemctl stop Cardchaind
sudo systemctl disable Cardchaind
rm /etc/systemd/system/Cardchaind.service
rm -Rvf $HOME/Cardchain
rm -Rvf $HOME/.Cardchaind
```
## Official links:
[Discord](https://discord.gg/Z3m2w5HE)

[Explorer](https://explorer.theamsolutions.info/Cardchain/staking)
