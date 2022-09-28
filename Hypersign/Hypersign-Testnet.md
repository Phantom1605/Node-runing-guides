## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev curl build-essential git jq ncdu bsdmainutils mc htop -y
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
git clone https://github.com/hypersign-protocol/hid-node.git
cd $HOME/hid-node
make install
cp $HOME/go/bin/hid-noded /usr/local/bin
hid-noded version
```
## Add variables:
```
echo 'export HID_MONIKER="your node moniker"'>> $HOME/.bash_profile
echo 'export HID_WALLET="your wallet name"'>> $HOME/.bash_profile
echo 'export HID_CHAIN="jagrat"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $HID_MONIKER
echo $HID_WALLET
echo $HID_CHAIN
```
## Init:
```
hid-noded init $HID_MONIKER --chain-id $HID_CHAIN
```
## Download genesis:
```
wget -qO $HOME/.hid-node/config/genesis.json "https://raw.githubusercontent.com/Phantom1605/Node-runing-guides/main/Hypersign/addrbook.json"
```
## Download addrbook.json
```
wget -qO $HOME/.hid-node/config/addrbook.json "https://raw.githubusercontent.com/sei-protocol/testnet/main/sei-incentivized-testnet/genesis.json"
```
## Add seeds and peers:
```
SEEDS=""
PEERS="7991e99ee8c05906a2161d8b47d826240da5c5d2@network.jagart.hypersign.id:26656,4625d4f9aa5034579134bdd551b6b54ee2b48c6a@network.jagart.hypersign.id:26656,85d140e4c211992d50285d93ba4cadc7d89410b5@38.242.206.64:26656,20e40949206d9d991274bfa388af4f77b7da0de1@176.100.3.29:26656,5cd888a5c37474ca778277cfd9dee7d24fe96094@95.217.214.107:26656,e0fe2fd7aa53edabf4978d96928d4d754d2140b0@23.88.55.152:26656,82fe77bca592a1dbcf747ad7f76847495bb4923e@65.108.151.238:26657,71043088812f947facd25b4f93c4eca73bc922f6@65.109.28.219:10956,cccc44f39832eaa9ae345fa92e47b553517765aa@207.180.197.147:26656,af22e60521ee775cad6ac83b4104783407df3fc2@172.104.184.55:26656,9aac6b663fa75bc1e50ad74aa8efa929e31fd3e4@178.250.242.94:26656,84408be4e3f13dcd976568d6370e1c50e9eb614d@185.252.232.110:46656,b0206e6ccd3ed9bfbb0feb9401faf27559742dc8@5.161.55.130:26656,776785ba52f350e10c0eaba22731e0891edb07fc@154.12.236.152:26656,c395620698af314d68a62df4217f5fd1aacad696@65.21.129.95:46636,d5f7dfff307cefb8e960000caf53b92dd9c58a1d@65.109.28.177:29227,14996170d73843813be594a03eb9690b95ea71bd@13.76.157.155:26656,6f95b7db6a293887dcd4b11137cd824f48c43f50@165.22.197.119:26657,77fbcaef349a10d628aac7f0832d450d4f869bdf@195.201.123.105:26656,5daa030db81056a177ac0b9d9aa0cdcaaef4e4c9@103.25.200.231:26656,69e7ff3d6bc66e3f1e5f1d0794643be4ace556fc@65.109.49.111:26456,ed12770cba24bfc5ea73d470115067bde00d8291@198.244.159.55:26656,2bd6f4bfb15c56cb1f179f9d921b37772dcfb9fa@5.161.154.109:36656,3990d5a402ca8f9e53441b02e22f4558c5c85fc5@65.108.44.149:27756,2128694e7da76a731b24d8bc059227748f0bc38d@144.91.100.18:26657,7bd5ca4aebb21d664939295c306ad6aef70b5604@95.161.27.57:26656,1dae68f061204fe2c10e9476239c0333258889e7@65.109.31.114:2460,ad06dd3131caea14bcbe809b5dc58c885859538e@38.242.216.207:26656,9f5079901be228be2a8686b4f17376441853ef26@65.108.52.192:56656,5b6356defbfc7227035698d6af7d686d3981a0eb@5.161.99.136:26656,bd8d56f381cde164db541a5764c6bf8f484fcf18@51.250.106.108:26656,70f00c612c1d681a04244749a56f3a35e9be1420@65.108.194.40:28765,839e1ee14102cc2a8c6616ab1a4cc96862cfccc3@95.217.131.157:26656,80a0eb37a75fbe0a66baa4c18a167ccaa7440a2c@95.216.156.201:26657,d5080fcee1b12910eee2ed35460b9046ecfd5dc3@139.162.235.100:26926,e32d544f129ae096dbc9f123de7f7af32ebf2ace@65.108.103.184:26656,98625e86ec117d277a58b8c576058189991ae6c0@65.108.206.56:13656,b441c4bfa215e8b46fe058e7a4ce4886d87860e3@132.145.54.94:26656,fd8a8905a404d4169e9a9ed7f4b034079e6a13ab@65.108.77.250:46151,06901d4cb4f0902e27c18ae19d5a67f3506b7d18@45.140.185.6:26656,8e4938aa6561695326f61f432ea2b2a53a428205@95.217.118.96:27161,4a020006964d92bd752bed55a2348828478b7da3@141.95.124.154:26656,1de2abae74a4c5fd7d96d9869ef02187f81498f0@134.209.238.66:26656,ea6ec9ba3f431e47c7baf8b07b5c752f0f1777a3@5.189.176.226:26657,c57cb8c929a73edff5cbad63a90d923edcf96913@34.168.39.191:26656,cf94099349980f9593a3f0362c85fe7c6eda8b14@8.219.48.59:26656,de1f980cc59bdb2457202768d4b4d964d783789e@167.235.21.165:26656,e9bf8e034cfb29658d252f81633ab91e9f28df26@143.198.163.38:26656,91089c0911b59f59fe2ec79fdae017f9beefbbfd@65.108.101.158:26656,af77f61922251db5860c98092246089cb4104865@109.74.200.157:26657,f3eaab835c004c3bc7119097de649cf35a14b48d@45.88.106.199:45656,33fd6e5062baedde026514357b6865f1fbc74c4f@185.144.99.15:26656,ac25bdc230944cc20f03913a8dae881c9b5f9c18@3.239.45.125:26656,55e8a3bc20328c23422e93d875db6dfd6d0adbf2@95.217.207.236:26656,789ca5ed1ee43c4fbf1258d1ec62edea5855dd50@20.42.111.34:26656,15d2f1bc2bfaa143388465ea115c59e5ce6e77dc@65.109.39.223:26656,7379f212d15f6256cf3cc452a6e50b787eccc8ec@161.97.102.31:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.hid-node/config/config.toml
```
## Configгure pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.hid-node/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.hid-node/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.hid-node/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.hid-node/config/app.toml
```
## Set minimum gas price:
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uhid\"/" $HOME/.hid-node/config/app.toml
```
## Unsafe reset all:
```
hid-noded tendermint unsafe-reset-all --home ~/.hid-node
```
## install service to run the node:
```
sudo tee /etc/systemd/system/hid-noded.service > /dev/null <<EOF
[Unit]
Description=hypersign
After=network-online.target

[Service]
User=$USER
ExecStart=$(which hid-noded) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable hid-noded
sudo systemctl restart hid-noded
sudo journalctl -u hid-noded -f -o cat
```
## Check your balance:
```
hid-noded q bank balances $(hid-noded keys show $HID_WALLET -a)
```
## Create validator:
```
hid-noded tx staking create-validator \
  --amount 100000000uhid \
  --pubkey  $(hid-noded tendermint show-validator) \
  --from $HID_WALLET \
  --moniker $HID_MONIKER \
  --chain-id $HID_CHAIN \
  --details="" \
  --website= "" \
  --identity="" \
  --min-self-delegation=1 \
  --commission-max-change-rate=0.01 \
  --commission-max-rate=0.2 \
  --commission-rate=0.06 
  ```
  ## Check your node status:
```
curl localhost:26657/status
hid-noded status 2>&1 | jq .SyncInfo
```
## Delegate tokens to your validator:
```
hid-noded tx staking delegate $(hid-noded keys show $HID_WALLET --bech val -a) <amounuhid> \
 --chain-id=$HID_CHAIN \
 --from=$HID_WALLET
```
## Collect rewards:
```
hid-noded tx distribution withdraw-all-rewards \
 --chain-id=$HID_CHAIN \
 --from $HID_WALLET 
```
## Unjail:
```
hid-noded tx slashing unjail \
 --chain-id $HID_CHAIN \ 
 --from $HID_WALLET
```
## Stop the node:
```
sudo systemctl stop hid-noded
```
## Delete node files and directories:
```
sudo systemctl stop hid-noded
sudo systemctl disable hid-noded
rm /etc/systemd/system/hid-noded.service
rm -Rvf $HOME/hid-noded
rm -Rvf $HOME/.hid-node
```
# If you have troubles with peers
```
hid-noded status 2>&1 | jq .SyncInfo
sudo systemctl stop hid-noded
wget -qO $HOME/.hid-node/config/addrbook.json "https://raw.githubusercontent.com/Phantom1605/Node-runing-guides/main/Hypersign/addrbook.json"

max_num_outbound_peers="50"
sed -i -e "s/^max_num_outbound_peers *=.*/max_num_outbound_peers = \"$max_num_outbound_peers\"/" $HOME/.hid-node/config/config.toml

hid-noded tendermint unsafe-reset-all --home ~/.hid-node

sudo systemctl restart hid-noded
sudo journalctl -u hid-noded -f -o cat
```

## Official links:

[Github](https://github.com/hypersign-protocol)

[Official website](https://hypersign.id)

[Discord](https://discord.gg/bFqnBAy5)

## Explorers
- https://exp.nodeist.net/T-Hypersign/staking
- https://explorer.kjnodes.com/hypersign/staking
- https://explorer.nodestake.top/hypersign-testnet
