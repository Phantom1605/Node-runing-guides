## Install dependencies:
```cd $HOME
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils -y
```
## Install Go:
```
wget -O go1.18.linux-amd64.tar.gz https://go.dev/dl/go1.18.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.linux-amd64.tar.gz && rm go1.18.linux-amd64.tar.gz

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
git clone https://github.com/sei-protocol/sei-chain.git
cd $HOME/sei-chain
git fetch origin --tags
git checkout v1.0.2-beta
```
## Install:
```
cd $HOME/sei-chain
make install
cp $HOME/go/bin/seid /usr/local/bin
```
## Verify installation:
Verify that everything is OK.
```
seid version --long | head
name: sei
server_name: seid
version: 1.0.2beta
commit: af556c64de7b9056d280f65f742f826b0c656a521
```
## Add variables:
```
echo 'export NODE_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export YOUR_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export CHAIN_ID="sei-testnet-2"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $NODE_MONIKER
echo $YOUR_WALLET
echo $CHAIN_ID
```
## Generate keys:
```
seid keys add $YOUR_WALLET
```
## Init:
```
seid init $NODE_MONIKER --chain-id $CHAIN_ID --recover
```
## Download genesis:
```
curl https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-testnet-2/genesis.json > ~/.sei/config/genesis.json
```
## Unsafe restart all:
```
seid tendermint unsafe-reset-all --home ~/.sei
```
## Download addrbook:
```
curl https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-testnet-2/addrbook.json > ~/.sei/config/addrbook.json
```
## Set minimum gas prices:
```
sed -i 's/minimum-gas-prices = ""/minimum-gas-prices = "0.01usei"/g' $HOME/.sei/config/app.toml
```
## install service to run the node:
```
sudo tee /etc/systemd/system/seid.service > /dev/null <<EOF
[Unit]
Description=Sei-Network Daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which seid) start
Restart=always
RestartSec=3
LimitNOFILE=65535
LimitMEMLOCK=209715200

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable seid
sudo systemctl restart seid
```
## Check your node logs:
```
journalctl -u seid -f
```
## Status of sinchronization:
```
seid status 2>&1 | jq .SyncInfo
curl http://localhost:26657/status | jq .result.sync_info.catching_up
```
## Faucet: 
Go to discord on the testnet-faucet channel

## Сheck your balance:
```
seid q bank balances $(seid keys show $YOUR_WALLET -a)
```
## Create validator:
```
seid tx staking create-validator \
  --amount 1000000usei \
  --commission-max-change-rate=0.01 \
  --commission-max-rate=0.2 \
  --commission-rate=0.1 \
  --min-self-delegation=1 \
  --details "" \
  --website=""\
  --identity= ""\
  --pubkey=$(seid tendermint show-validator) \
  --moniker=$NODE_MONIKER \
  --chain-id=$CHAIN_ID \
  --fees="2000usei"
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
 --chain-id=$CHAIN_ID \
 --from $YOUR_WALLET \
 --gas auto \
 --gas-adjustment=1.4 \
```
## Delegate tokens to your validator:
```
seid tx staking delegate $(seid keys show $YOUR_TEST_WALLET --bech val -a) <amountusei> \
--chain-id=$CHAIN_ID \
--from=$YOUR_WALLET \
--gas auto \
--gas-adjustment=1.4 \
```
## Unjail:
```
seid tx slashing unjail \
--chain-id $CHAIN_ID \ 
--from $YOUR_WALLET \ 
--gas=auto \ 
--gas-adjustment=1.4 \
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
rm -Rvf $HOME/sei
rm -Rvf $HOME/.sei
```
Official links:

[Discord](https://discord.gg/YpYQ77Db)

[Official documentations](https://docs.seinetwork.io/nodes-and-validators/joining-testnets)

[Medium](https://medium.com/@seinetwork)
