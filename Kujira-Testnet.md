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

## Add variobles:
```
echo 'export NODE_MONIKER="Your node moniker"'>> $HOME/.bash_profile
echo 'export YOUR_WALLET="You wallet name"'>> $HOME/.bash_profile
echo 'export CHAIN_ID="harpoon-3"' >> $HOME/.bash_profile
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
seeds="8e1590558d8fede2f8c9405b7ef550ff455ce842@51.79.30.9:26656,bfffaf3b2c38292bd0aa2a3efe59f210f49b5793@51.91.208.71:26656,106c6974096ca8224f20a85396155979dbd2fb09@198.244.141.176:26656"
peers="111ba4e5ae97d5f294294ea6ca03c17506465ec5@208.68.39.221:26656,b16142de5e7d89ee87f36d3bbdd2c2356ca2509a@75.119.155.248:26656,ad7b2ecb931a926d60d1e034d0e37a83d0e265f1@109.107.181.127:26656,1b827c298f013900476c2eab25ce5ff75a6f8700@178.63.62.212:26656,111ba4e5ae97d5f294294ea6ca03c17506465ec5@208.68.39.221:26656,f114c02efc5aa7ee3ee6733d806a1fae2fbfb66b@5.189.178.222:46656,8980faac5295875a5ecd987a99392b9da56c9848@85.10.216.151:26656,3c3170f0bcbdcc1bef12ed7b92e8e03d634adf4e@65.108.103.236:27656"

sed -i "s/^seeds *=.*/seeds = \"$seeds\"/;" $HOME/.kujira/config/config.toml
sed -i "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/;" $HOME/.kujira/config/config.toml
```
## Configure pruning:
```
sed -i "s/pruning *=.*/pruning = \"custom\"/g" $HOME/.kujira/config/app.toml
sed -i "s/pruning-keep-recent *=.*/pruning-keep-recent = \"809\"/g" $HOME/.kujira/config/app.toml
sed -i "s/pruning-interval *=.*/pruning-interval = \"43\"/g" $HOME/.kujira/config/app.toml
#sed -i.bak -e "s/indexer *=.*/indexer = \"null\"/g" $HOME/.kujira/config/config.toml
sed -i "s/index-events =.*/index-events = [\"tx.hash\",\"tx.height\"]/g" $HOME/.kujira/config/app.toml
```
## Unsafe restart all:
```
kujirad tendermint unsafe-reset-all
```
## Download addrbook:
```
wget -O $HOME/.kujira/config/addrbook.json https://raw.githubusercontent.com/Team-Kujira/networks/master/testnet/addrbook.json
```

## install service to run the node:
```
sudo tee /etc/systemd/system/kujirad.service > /dev/null <<'EOF'
[Unit]
Description=Kujirad Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which kujirad) start
Restart=on-failure
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
Storage=persistent
EOF

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
## Faucet:
Get tokens in the faucet, change YOUR_WALLET_ADDRESS on your wallet address.
```
curl -X POST https://faucet.kujirad.app/YOUR WAllET_ADDRESS
```
## Сheck your balance:
```
kujirad q bank balances $(kujirad keys show $YOUR_WALLET -a)
```
## Create validator:
```
kujirad tx staking create-validator \
--moniker=$NODE_MONIKER \
--amount=10000000ukuji \
--gas-prices=1ukuji \
--pubkey=$(kujirad tendermint show-validator) \
--chain-id=$CHAIN_ID \
--commission-max-change-rate=0.01 \
--commission-max-rate=0.20 \
--commission-rate=0.10 \
--min-self-delegation=1 \
--from=$YOUR_WALLET \
--yes \
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
 --gas-prices=1ukuji
```
### Delegate tokens to your validator:
```
kujirad tx staking delegate $(kujirad keys show $YOUR_WALLET --bech val -a) <amountukuji> \
--chain-id=$CHAIN_ID \
--from=$YOUR_WALLET \
--fees 1000ukuji
```
### Unjail:
```
kujirad tx slashing unjail \
--chain-id $CHAIN_ID \ 
--from $YOUR_WALLET \  
--gas-prices=1ukuji
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
