## Install dependencies:
```cd $HOME
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils curl -y
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
## Clone git repository and install:
```
cd $HOME
git clone https://github.com/sei-protocol/sei-chain.git
cd sei-chain
git checkout 1.1.2beta-internal
make install 
cp $HOME/go/bin/seid /usr/local/bin
```
## Add variables:
```
echo 'export SEI_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export SEI_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export SEI_CHAIN="atlantic-sub-1"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $SEI_MONIKER
echo $SEI_WALLET
echo $SEI_CHAIN
```
## Init:
```
seid init $SEI_MONIKER --chain-id $SEI_CHAIN
```
## Recover or create new wallet:
* create new wallet:
```
seid keys add $SEI_WALLET
```
* recover existing wallet:
```
seid keys add $SEI_WALLET --recover
```
## Download genesis:
```
wget -qO $HOME/.sei/config/genesis.json "https://raw.githubusercontent.com/sei-protocol/testnet/main/atlantic-subchains/atlantic-sub-1/genesis.json""
```
## Set seeds and peers:
```
SEEDS="" ; \
PEERS="9cb4671ad53606854e4aa3503f6d336395e1d62e@65.109.18.179:26656,3de8fc796c516f4cfe9203746ef371da614e25d0@65.108.231.252:26656,38b4d78c7d6582fb170f6c19330a7e37e6964212@65.109.49.111:26656,98ae02a9f85ff0c99c159cf2ac985175d248aebe@185.202.223.85:26656,7f1970d704045b9908a18e9ec35c6b942c73ccfb@212.23.222.28:26656,768e01370da13677800211f1aa104bd800eef38d@65.108.231.253:26656,973fde4668578c9c31ee4fe348adc791298e7413@172.31.27.126:26656,76d4edb6049b2c2aa139fb0dcceb1370f830e1a0@95.217.176.153:26656,3de8fc796c516f4cfe9203746ef371da614e25d0@65.108.231.252:36656,9f051e85c0bb3ad38302caffb9d0cd716c84d36c@95.216.21.32:12656" ; \
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.sei/config/config.toml
```
## Configure pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.sei/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.sei/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.sei/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.sei/config/app.toml
```
## Set minimum gas prices:
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0usei\"/" $HOME/.sei/config/app.toml
```
## Unsafe restart all:
```
seid tendermint unsafe-reset-all --home $HOME/.sei
```
## install service to run the node:
```
sudo tee /etc/systemd/system/seid.service > /dev/null <<EOF
[Unit]
Description=sei
After=network-online.target

[Service]
User=$USER
ExecStart=$(which seid) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable seid
sudo systemctl restart seid
```
## Check your node logs:
```
journalctl -u seid -f -o cat
```
## Status of sinchronization:
```
seid status 2>&1 | jq .SyncInfo
curl http://localhost:26657/status | jq .result.sync_info.catching_up
```
## Faucet: 
Go to discord on the atlantic fauset channel

## Сheck your balance:
```
seid q bank balances $(seid keys show $SEI_WALLET -a)
```
## Create validator:
```
seid tx staking create-validator \
 --amount 1000000usei \
 --from $SEI_WALLET \
 --commission-max-change-rate=0.01 \
 --commission-max-rate=0.2 \
 --commission-rate=0.08 \
 --min-self-delegation=1 \
 --details "" \
 --website=""\
 --identity= ""\
 --pubkey=$(seid tendermint show-validator) \
 --moniker=$SEI_MONIKER \
 --chain-id=$SEI_CHAIN
```
## Check your node status:
```
curl localhost:26657/status
```
## Verify that your validator is active:
```
seid query tendermint-validator-set | grep "$(seid tendermint show-validator | jq -r .key)"
```
## Collect rewards:
```
seid tx distribution withdraw-all-rewards \
 --chain-id=$SEI_CHAIN \
 --from=$SEI_WALLET
```
## Delegate tokens to your validator:
```
seid tx staking delegate $(seid keys show $SEI_WALLET --bech val -a) <amountusei> \
 --chain-id=$SEI_CHAIN \
 --from=$SEI_WALLET
```
## Unjail:
```
seid tx slashing unjail \
 --chain-id=$SEI_CHAIN \ 
 --from=$SEI_WALLET
```
## Stop the node:
```
sudo systemctl stop seid
```
## Delete node files and directories:
```
sudo systemctl stop seid
sudo systemctl disable seid
rm /etc/systemd/system/seid.service
rm -Rvf $HOME/sei-chain
rm -Rvf $HOME/.sei
```
## Official links:

[Discord](https://discord.gg/4XD3PnhH)

[Official documentations](https://docs.seinetwork.io/nodes-and-validators/joining-testnets)

[Medium](https://medium.com/@seinetwork)

[Explorer](https://sei.explorers.guru/validators)
