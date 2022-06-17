## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils htop -y < "/dev/null" -y
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
## Download & Install:
```
wget -qO - https://github.com/palomachain/paloma/releases/download/v0.1.0-alpha/paloma_0.1.0-alpha_Linux_x86_64v3.tar.gz | \
sudo tar -C /usr/local/bin -xvzf - palomad
sudo chmod +x /usr/local/bin/palomad
sudo wget -P /usr/lib https://github.com/CosmWasm/wasmvm/raw/main/api/libwasmvm.x86_64.so
```
## Add variables:
```
echo 'export YOUR_MONIKER="You node moniker"'>> $HOME/.bash_profile
echo 'export YOUR_WALLET="You wallet name"'>> $HOME/.bash_profile
echo 'export CHAIN_ID="paloma"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $YOUR_MONIKER
echo $YOUR_WALLET
echo $CHAIN_ID
```
## Init:
```
palomad init $YOUR_MONIKER --chain-id $CHAIN_ID
```
## Generate keys:
```
palomad keys add $YOUR_WALLET
```
## Download genesis:
```
wget -qO $HOME/.paloma/config/genesis.json "https://raw.githubusercontent.com/palomachain/testnet/master/livia/genesis.json"
```
## Download adrrbook
```
wget -qO $HOME/.paloma/config/addrbook.json "https://raw.githubusercontent.com/palomachain/testnet/master/livia/addrbook.json"
```
## Configure you node:
```
# Set seeds and peers: 
SEEDS=""
PEERS="223e39487e0e363833f19ead57c3bb98303730f9@116.202.112.175:26601,2e0623d133e8da778e379b01ea0b8cb477f5b346@135.181.116.109:38456,61db8ce4cf4e9c0cbbb9bfb4c90ae6d02c17d6bd@138.201.139.175:20456,eed0ef9a854fd601401d5484d64cb3e0b02a955b@144.126.135.27:46656,5cea05a8c5dffacd0ce022e1726734a0d8cbfdca@62.141.39.178:26656,1003cf3b68ddfd3a55bb20f5c6041c1efe2e52eb@65.21.143.79:21556,d8d619448fef295ac11463b834b4a169dbf8f9ba@135.181.47.192:26656,ebeca6a40fba2c3a3aa5a9c99d9222163bd6d4c6@95.216.154.164:26656,927cc47316c0530b54a711e601b14a1fb24c0153@62.171.128.66:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.paloma/config/config.toml

# Set minimum gasprice:
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0grain\"/" $HOME/.paloma/config/app.toml
```
## Configure pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"

sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.paloma/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.paloma/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.paloma/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.paloma/config/app.toml
```
## Unsafe restart all:
```
palomad tendermint unsafe-reset-all
```
## install service to run the node:
```
sudo tee /etc/systemd/system/palomad.service > /dev/null <<EOF
[Unit]
Description=paloma
After=network-online.target

[Service]
User=$USER
ExecStart=$(which palomad) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable palomad
sudo systemctl restart palomad
sudo journalctl -u palomad -f -o cat
```
## Check your node logs:
```
journalctl -u kujirad -f -o cat
```
## Status of sinchronization:
```
curl http://localhost:26657/status | jq .result.sync_info.catching_up
```
## Сheck your balance:
```
palomad q bank balances $(palomad keys show $YOUR_WALLET -a)
```
## Create validator:
```
palomad tx staking create-validator \
 --amount 100000000grain \
 --from=$YOUR_WALLET \
 --commission-max-change-rate=0.01 \
 --commission-max-rate=0.2 \
 --commission-rate=0.07 \
 --website=""\
 --identity="" \
 --min-self-delegation=1 \
 --pubkey=$(palomad tendermint show-validator) \
 --moniker=$YOUR_MONIKER \
 --chain-id=$CHAIN_ID
```
## Useful commands:
### Check your node logs:
```
journalctl -u palomad -f -o cat
```
### Status of sinchronization:
```
curl -s localhost:26657/status | jq .result.sync_info.catching_up
```
### Get your valoper address:
```
palomad keys show $YOUR_WALLET --bech val -a
```
### Collect rewards:
```
palomad tx distribution withdraw-all-rewards \
 --chain-id=$CHAIN_ID \
 --from $YOUR_WALLET \
 --gas=auto
 ```
### Delegate tokens to your validator:
```
palomad tx staking delegate $(palomad keys show $YOUR_WALLET --bech val -a) <amountgrain> \
--chain-id=$CHAIN_ID \
--from=$YOUR_WALLET \
--gas=auto
  ```
### Unjail:
```
palomad tx slashing unjail \
--broadcast-mode=block \
--chain-id $CHAIN_ID \ 
--from $YOUR_WALLET \  
--gas=auto
```
### Stop the node:
```
sudo systemctl stop palomad
```
### Delete node files and directories:
```
sudo systemctl stop palomad
sudo systemctl disable palomad
rm /etc/systemd/system/palomad.service
rm -Rvf $HOME/paloma
rm -Rvf $HOME/.paloma
```
## Official links:
[Telegram](https://t.me/palomachain)


