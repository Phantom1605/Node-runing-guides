## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev curl build-essential git jq ncdu bsdmainutils mc htop -y
```
## Install Go:
```
wget -O go1.19.2.linux-amd64.tar.gz https://golang.org/dl/go1.19.2.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.2.linux-amd64.tar.gz && rm go1.19.2.linux-amd64.tar.gz
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
git clone https://github.com/NibiruChain/nibiru
cd nibiru
git checkout v0.19.2
make install
nibid version
cp $HOME/go/bin/nibid /usr/local/bin
```
## Add variables:
```
echo 'export NIBIRU_MONIKER="your node moniker"'>> $HOME/.bash_profile
echo 'export NIBIRU_WALLET="your wallet name"'>> $HOME/.bash_profile
echo 'export NIBIRU_CHAIN="nibiru-itn-1"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $NIBIRU_MONIKER
echo $NIBIRU_WALLET
echo $NIBIRU_CHAIN
```
## Init:
```
defundd init $NIBIRU_MONIKER --chain-id $NIBIRU_CHAIN
```
## Recover or create new wallet:
* create new wallet:
```
nibid keys add $NIBIRU_WALLET
```
* recover existing wallet:
```
nibid keys add $NIBIRU_WALLET --recover
```
## Dowload genesis:
```
curl -s https://rpc.itn-1.nibiru.fi/genesis | jq -r .result.genesis > $HOME/.nibid/config/genesis.json
```
## Set seeds:
```
sed -i -e "s|seeds =.*|seeds = "'$(curl -s https://networks.itn.nibiru.fi/$NETWORK_NIBIRU/seeds)'"/" $HOME/.nibid/config/config.toml
```
## Set peers:
```
PEERS="ac163da500a9a1654f5bf74179e273e2fb212a75@65.108.238.147:27656,abab2c6f45fa865dc61b2757e21c5d2244e5bacb@213.202.218.55:26656,fe17db7c9a5f8478a2d6a39dbf77c4dc2d6d7232@5.75.189.135:26656,baff3597ebd19ce273b7c0b56e2d50a8964d1423@65.109.90.166:26656,ca6213c897bd8400d8d01b947a541db85ebb2d96@51.89.199.49:36656,63256b5937ac438e3b21b570a07ace6ddc3bd0c6@194.163.182.122:39656,c1b40d056e4260a9fa9d1142af1adbeec5039599@142.132.202.50:46656,ea44a000ee4df9d722a90fdf41b3990e738bdda0@65.109.235.95:26656,7e75b2249d088a4dfc3b33f386c316cb47366d2b@195.3.221.48:11656,e08089921baf39382920a4028db9e5eebd82f3d7@142.132.199.236:21656,2484b3b0912815869317e1da43a409b9ffd6653e@154.12.244.128:26656,9946c87d01312752d26fe0ceef4f4e24707f8144@65.109.88.178:27656,d327bb6b997a32aaa7dae5673e9a9cbad487ad09@104.156.250.70:26656,4f1af4f62f76c095d844384a3dfa1ad76ad5c078@65.108.206.118:60656,6052d09554a442f22f71c33dbc5f25bee538e087@65.109.82.249:28656,c4124e6623529b31b8c535be1ea8835aa7ff51b0@51.79.77.103:28656,2dce4b0844754b467ae40c9d6360ac51836fadca@135.181.221.186:29656,c8907a13b012e7a937cfe7d624b0fbe7ef3508b2@194.163.160.155:26656,0ebf64601e93d0e5304da8b7d3deb96d7d7cbcf8@176.120.177.123:26656,30e14f66fc44a55a51f36693afd754283c668953@65.108.200.60:11656,fa5c730d842aff05c3761d9c1b06107340ac7651@65.108.232.238:11656,f01ad3a75b255226499df9183ac2ebc0a40a9e05@46.4.53.207:33656,81a8383eefae628ae4bc400d52d49adfb11cb76a@65.108.108.52:11656,1c548375968f0abfac3733cae9f592468c988bf9@46.4.53.209:33656,f4a6bcbd4af5cfd82ee3a40c54800176e33e9477@31.220.79.15:26656,b03d1ce3e97984a8b8a63a7a6ec6c5d196d81436@46.4.53.208:33656,e74f1204d65d0264547e2c2d917c23c39fcff774@95.217.107.96:36656,b316ff6b5a0715732fa02f990db94aef39e758b3@148.251.88.145:10156,79e2bfc202e39ba2a168becc4c75cb6a56803e38@135.181.57.104:11656,22d5b4919850ad71ad0a1bf7979c7dba53960689@192.9.134.157:27656,2686c58fc276fff2956bf1b10736244737f84c9b@178.208.86.44:26656,a3a344c1732c507f40931778225f919004392e94@52.204.188.236:26656,84d888be939b738d343db0613d4cc50a33f36beb@158.101.208.86:26656,21ad250f917fafcd9bca8ea223558dffc6bd75c4@38.242.205.18:26656,1848442cbab24bc7123ad2dec2464661b5bc92c1@94.190.90.38:28656,e9b25db508b31cb9d48b1f0b67147faf8c2b7b0b@65.108.199.206:27656"
sed -i -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.nibid/config/config.toml
```
## Set custom ports:
```
DEFUND_PORT=34
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NIBIRU_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NIBIRU_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NIBIRU_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NIBIRU_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NIBIRU_PORT}660\"%" $HOME/.nibidd/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${NIBIRU_PORT}317\"%; s%^address = \":8080\"%address = \":${NIBIRU_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${NIBIRU_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NIBIRU_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${NIBIRU_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${NIBIRU_PORT}546\"%" $HOME/.nibidd/config/app.toml
```
## Config node:
```
nibid config node tcp://localhost:34657
```
## Config pruning:
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.nibid/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.nibid/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.nibid/config/app.toml
```
## Set minimum gas price:
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025unibi\"/" $HOME/.nibid/config/app.toml
```
## Unsefe reset all:
```
nibid tendermint unsafe-reset-all --home ~/.nibid
```
## Create servise file:
```
sudo tee /etc/systemd/system/nibid.service > /dev/null <<EOF
[Unit]
Description=nibiru
After=network-online.target

[Service]
User=$USER
ExecStart=$(which defundd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable nibid
sudo systemctl daemon-nibid
sudo systemctl restart nibid
sudo systemctl status nibid
```
## Check your node logs:
```
sudo journalctl -u nibid -f -o cat
```
## Status of sinchronization:
```
nibid status 2>&1 | jq .SyncInfo
curl http://localhost:34657/status | jq .result.sync_info.catching_up
```
## Check Node ID:
```
curl localhost:34657/status | jq '.result.node_info.id'
```
## Faucet:
* You can go to their [application] (https://app.nibiru.fi/), connect your Kepler wallet and request tokens, or do it manually via the terminal.
```
FAUCET_URL="https://faucet.itn-1.nibiru.fi/"
curl -X POST -d '{"address": "'"$ADDR"'", "coins": ["11000000unibi","100000000unusd","100000000uusdt"]}' $FAUCET_URL
```
## Check your balance:
```
nibid q bank balances $(nibid keys show $NIBIRU_WALLET -a)
```
## Create validator:
```
nibid tx staking create-validator \
--amount 10000000unibi \
--pubkey  $(nibid tendermint show-validator) \
--from $NIBIRU_WALLET \
--moniker $NIBIRU_MONIKER \
--chain-id $NIBIRU_CHAIN \
--details="" \
--website= "" \
--identity="" \
--min-self-delegation=1 \
--commission-max-change-rate=0.1 \
--commission-max-rate=0.2 \
--commission-rate=0.1 \
--gas-prices 0.025unibi
  ```
  ## Check your node status:
```
curl localhost:34657/status | jq
```
## Withdraw rewards:
```
nibid tx distribution withdraw-all-rewards \
--from $NIBIRU_WALLET \
--chain-id=$NIBIRU_CHAIN \
--gas-prices 0.025unibi 
```
## Withdraw validator commission:
```
nibid tx distribution withdraw-rewards $(nibid keys show $NIBIRU_WALLET --bech val -a) \
--chain-id $NIBIRU_CHAIN \
--from $NIBIRU_WALLET \
--gas-prices 0.025unibi \
--commission \
--yes
```
## Delegate tokens to your validator:
```
nibid tx staking delegate $(nibid keys show $DEFUND_WALLET --bech val -a) <amontunibi> \
--chain-id=$NIBIRU_CHAIN \
--from=$NIBIRU_WALLET \
--gas-prices 0.025unibi
```
## Unjail:
```
nibid tx slashing unjail \
--from $NIBIRU_WALLET \
--chain-id=$NIBIRU_CHAIN \
--gas-prices 0.025unibi
```
## Stop the node:
```
sudo systemctl stop nibid
```
## Delete node files and directories:
```
sudo systemctl stop nibid
sudo systemctl disable nibid
rm /etc/systemd/system/nibid.service
rm -Rvf $HOME/nibiru
rm -Rvf $HOME/.nibid
```
## Official links:

[Discord](https://discord.gg/nibiru)

[Explorer](https://explorer.kjnodes.com/nibiru-testnet/staking)

[Official instructions](https://docs.nibiru.fi/)

[Official site](https://nibiru.fi/)

[NIbiru application](https://app.nibiru.fi/)
