## Install dependencies:
```cd $HOME
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
## Clone git repository:
```
rm -rf $HOME/kujira-core
git clone https://github.com/Team-Kujira/core $HOME/kujira-core
```
## Install:
```
cd $HOME/kujira-core
make install
cp $HOME/go/bin/kujirad /usr/local/bin
```

## Add variables:
```
echo 'export NODE_MONIKER="Your node moniker"'>> $HOME/.bash_profile
echo 'export YOUR_WALLET="You wallet name"'>> $HOME/.bash_profile
echo 'export CHAIN_ID="harpoon-4"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $NODE_MONIKER
echo $YOUR_WALLET
echo $CHAIN_ID
```
## Generate keys:
```
kujirad keys add $YOUR_WALLET
```

## Init:
```
kujirad init $NODE_MONIKER --chain-id $CHAIN_ID --recover
```
## Download genesis:
```
wget -O $HOME/.kujira/config/genesis.json https://raw.githubusercontent.com/Team-Kujira/networks/master/testnet/harpoon-3.json
```
## Configure your node:
```
#set minimum gas price:

sed -i -e "s/^minimum-gas-prices =./minimum-gas-prices = "0.00125ukuji"/" $HOME/.kujira/config/app.toml
sed -i -e "s/^timeout_commit =./timeout_commit = "1500ms"/" $HOME/.kujira/config/config.toml``

#set peers and seeds
SEEDS=""
PEERS="87ea1a43e7eecdd54399551b767599921e170399@52.215.221.93:26656,021b782ba721e799cd3d5a940fc4bdad4264b148@65.108.103.236:16656,1d6f841271a1a3f78c6772b480523f3bb09b0b0b@15.235.47.99:26656,ccd2861990a98dc6b3787451485b2213dd3805fa@185.144.99.234:26656,909b8da1ea042a75e0e5c10dc55f37711d640388@95.216.208.150:53756,235d6ac8aebf5b6d1e6d46747958c6c6ff394e49@95.111.245.104:26656,b525548dd8bb95d93903b3635f5d119523b3045a@194.163.142.29:26656,26876aff0abd62e0ab14724b3984af6661a78293@139.59.38.171:36347,21fb5e54874ea84a9769ac61d29c4ff1d380f8ec@188.132.128.149:25656,06ebd0b308950d5b5a0e0d81096befe5ba07e0b3@193.31.118.143:25656,f9ee35cf9aec3010f26b02e5b3354efaf1c02d53@116.203.135.192:26656,c014d76c1a0d1e0d60c7a701a7eff5d639c6237c@157.90.179.182:29656,0ae4b755e3da85c7e3d35ce31c9338cb648bba61@164.92.187.133:26656,202a3d8bd5a0e151ced025fc9cbff606845c6435@49.12.222.155:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.kujira/config/config.toml
```
## Configure pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.kujira/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.kujira/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.kujira/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.kujira/config/app.toml
```
## Unsafe restart all:
```
kujirad tendermint unsafe-reset-all
```
## install service to run the node:
```
sudo tee /etc/systemd/system/kujirad.service > /dev/null <<EOF
[Unit]
Description=kujira
After=network-online.target

[Service]
User=$USER
ExecStart=$(which kujirad) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable kujirad
sudo systemctl restart kujirad
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
kujirad q bank balances $(kujirad keys show $YOUR_WALLET -a)
```
## Create validator:
```
kujirad tx staking create-validator \
 --amount 100000000ukuji \
 --from=$YOUR_WALLET \
 --commission-max-change-rate=0.01 \
 --commission-max-rate=0.20 \
 --commission-rate=0.07 \
 --website=https:""\
 --identity="" \
 --min-self-delegation=1 \
 --pubkey  $(kujirad tendermint show-validator) \
 --moniker $NODE_MONIKER \
 --fees 300ukuji \
 --chain-id $CHAIN_ID
```

## Useful commands:

### Check your node logs:
```
journalctl -u kujirad -f -o cat
```
### Status of sinchronization:
```
curl -s localhost:26657/status | jq .result.sync_info.catching_up
```
### Get your valoper address:
```
kujirad keys show $YOUR_WALLET --bech val -a
```
### Collect rewards:
```
kujirad tx distribution withdraw-all-rewards \
 --chain-id=$CHAIN_ID \
 --from $YOUR_WALLET \
 --gas-prices=1ukuji \
 --fees 5000ukuji \                                                              
```
### Delegate tokens to your validator:
```
kujirad tx staking delegate $(kujirad keys show $YOUR_WALLET --bech val -a) <amountukuji> \
--chain-id=$CHAIN_ID \
--from=$YOUR_WALLET \
--fees 5000ukuji \
```
### Unjail:
```
kujirad tx slashing unjail \
--chain-id $CHAIN_ID \ 
--from $YOUR_WALLET \  
--fees 5000ukuji \
```
### Stop the node:
```
sudo systemctl stop kujirad
```
### Delete node files and directories:
```
sudo systemctl stop kujirad
sudo systemctl disable kujirad
rm /etc/systemd/system/kudjirad.service
rm -Rvf $HOME/kudjira
rm -Rvf $HOME/.kujira
```

## Official links:
1. [Discord](https://discord.com/invite/P8ErHe9E2Z)
2. [Github](https://github.com/Team-Kujira)
3. [Medium](https://teamkujira.medium.com)
