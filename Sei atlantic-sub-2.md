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
echo 'export SEI_CHAIN="atlantic-sub-2"' >> $HOME/.bash_profile
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
wget -qO $HOME/.sei/config/genesis.json "https://raw.githubusercontent.com/sei-protocol/testnet/main/atlantic-subchains/atlantic-sub-2/genesis.json"
```
## Set seeds and peers:
```
SEEDS="" ; \
PEERS="f48eedfb31854a822129b7f857b43969f2526bad@185.144.99.19:26656,2f1e8842dec0a60c79d8fedfe420697661c837c8@195.3.221.191:26656,f61d6ace9a30d371fa2d1b8e04ec11b66c967a63@167.235.6.228:26656,070650355f3e51d5f1f514759ec7602b993588f1@185.248.24.16:26656,e528e2d19e1b611894745fc1a5d3e7802e606f31@95.214.52.173:26656,dd23e8a8f019ff8030a1238f7cbf99601293050e@213.239.218.199:26656,34c734f3908654b53045f06c5fd262efaa6c0766@65.109.27.156:26656,72e5106ce49cb794f8af7196a14916bc06a36465@5.161.75.216:26656,7900d390baf8e6d5ce69225917e8fd64927e94f2@154.12.240.133:26656,8acf073665a756fca2df91b647a280ef0d05dc8a@85.114.134.203:26656,263803aef62e933f568ced5df5ca2e24d0f9d329@95.216.40.123:26656,5cb50c4b80dff5a92d232057d07f97ab82895cea@65.108.246.4:26656,0174c55cc5fb6c7ad0c39e709710adfb1ee6bae8@49.12.15.138:26656,26ff7747fd64c703bd241bdad3cf75bbda5ae72b@85.10.199.157:26656,390be417d37cb2ac0ee72a7c40f2ead6aa98e62b@65.108.60.151:26656,5d0cee85dcac7364fb8861201eec3a767873bdf3@172.31.16.93:26656,62ec353a7c234ef436518a7d07eed422064c01c9@172.31.16.93:26656,2743782c2bdc22e51250c5edc21048d1e3a7bf01@172.20.0.75:26656,2743782c2bdc22e51250c5edc21048d1e3a7bf01@172.20.0.75:26656,a5b5ee5888f4a8b66a29184611dd19e4c8ce1c28@5.9.71.9:26656,aaa1da62895d2a8daaf09b235ca82a55c8d9efd7@173.212.203.238:26656,ab082b683c6ecfb1148cb87e0153b036b1ea2283@65.108.199.62:26656,169685c8550d1663ac44a77d8bb03ba681a9582d@45.84.138.127:26656,b2a4e16ef6ec4e2e42ec7c22e530840c16351bfa@135.181.222.185:26656,89ba32810d917a9db78808df338b60abcb7ae3e2@45.94.209.32:26656,e84bbca3bd80c9effba4451dd797a0edb61cb5d2@135.181.143.26:26656,531980d9574d1c619aad8ba9f42703c2c817d9f8@38.242.255.82:26656" ; \
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
