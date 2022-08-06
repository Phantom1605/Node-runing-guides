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
git clone https://github.com/sei-protocol/sei-chain.git
cd $HOME/sei-chain
git checkout 1.0.6beta
make install
cp $HOME/go/bin/seid /usr/local/bin
```
## Add variables:
```
echo 'export SEI_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export SEI_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export SEI_CHAIN="atlantic-1"' >> $HOME/.bash_profile
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
## Download genesis and addrbook:
```
wget -qO $HOME/.sei/config/genesis.json "https://raw.githubusercontent.com/sei-protocol/testnet/main/sei-incentivized-testnet/genesis.json"
wget -qO $HOME/.sei/config/addrbook.json "https://raw.githubusercontent.com/sei-protocol/testnet/main/sei-incentivized-testnet/addrbook.json"
```
## Set seeds and peers:
```
SEEDS="df1f6617ff5acdc85d9daa890300a57a9d956e5e@sei-atlantic-1.seed.rhinostake.com:16660"
PEERS="22991efaa49dbaae857669d44cb564406a244811@18.222.18.162:26656,a37d65086e78865929ccb7388146fb93664223f7@18.144.13.149:26656,873a358b46b07c0c7c0280397a5ad27954a10633@141.95.175.196:26656,e66f9a9cab4428bfa3a7f32abbedbc684e734a48@185.193.17.129:12656,16225e262a0d38fe73073ab199f583e4a607e471@135.181.59.162:19656,2efd524f097b3fef2d26d0031fda21a72a51a765@38.242.213.174:12656,3b5ae3a1691d4ed24e67d7fe1499bc081c3ad8b0@65.108.131.189:20956,ad6d30dc6805df4f48b49d9013bbb921a5713fa6@20.211.82.153:26656,4e53c634e89f7b7ecff98e0d64a684269403dd78@38.242.235.141:26656,da5f6fcd1cd2ba8c7de8a06fb3ab56ab6a8157cf@38.242.235.142:26656,89e7d8c9eefc1c9a9b3e1faff31c67e0674f9c08@165.227.11.230:26656,94b6fa7ae5554c22e81a81e4a0928c48e41801d8@88.99.3.158:10956,b95aa07e60928fbc5ba7da9b6fe8c51798bd40be@51.250.6.195:26656,94b72206c0b0007494e20e2f9b958cd57e970d48@209.145.50.102:26656,94cf3893ded18bc6e3991d5add88449cd3f6c297@65.108.230.75:26656,82de728de0d663c03a820e570b94adac19c09adf@5.9.80.215:26656,5e1f8ccfa64dfd1c17e3fdac0dbf50f5fcc1acc3@209.126.7.113:26656,6a5113e8412f68bbeab733bb1297a0a38f884f7c@162.55.80.116:26656,7c95b2eec599369bebb8281b960589dc2857548a@164.215.102.44:26656,4bf8aa7b80f4db8a6f2abf5d757c9cab5d3f4d85@188.40.98.169:26656,9e38cf7ccb898632482a09b26ecba3f7e1a9e300@51.75.135.46:26656,641eea8d26c4b3b479b95a2cb4bd04712f3eda29@135.181.249.71:12656,8625abf6079da0e3326b0ad74c9c0e263af39654@137.184.44.146:12656,11c84300b4417af7e6c081f413003176b33b3877@51.75.135.47:26656,8a349512cf1ce179a126cb8762aea955ca1a261f@195.201.243.40:26651,6c27c768936ff8eebde94fe898b54df71f936e48@47.156.153.124:56656,7f037abdf485d02b95e50e9ba481166ddd6d6cae@185.144.99.65:26656,90916e0b118f2c00e90a40a0180b275261b547f2@65.108.72.121:26656,02be57dc6d6491bf272b823afb81f24d61243e1e@141.94.139.233:26656,ed3ec09ab24b8fcf0a36bc80de4b97f1e379d346@38.242.206.198:26656,7caa7add8d8a279e2da67a72700ab2d4540fbc08@34.97.43.89:12656,cce4c3526409ec516107db695233f9b047d52bf6@128.199.59.125:36376,3f6e68bd476a7cd3f491105da50306f8ebb74643@65.21.143.79:21156"
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
