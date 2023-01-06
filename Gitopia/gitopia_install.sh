#!/bin/bash

echo -e "\033[0;35m"
echo -e "\033[1;34m"
echo -e "AlexAlexAleAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlex"
echo -e "AlexAlexAleAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlex"
echo -e "\033[1;36m"
echo -e "        ###       ###       #######   ##      ##     ########    ##     ##    ######## "
echo -e "       #####      ###     ###     ##   ##    ##     ##      ##   ##     ##   ###       "
echo -e "      ### ###     ###    ##       ##    ##  ##      ##      ##   ##     ##    ######   "
echo -e "     ###   ###    ###   ############      ##        ##########    ########          ## "
echo -e "    ###########   ###   ##                ##        ##      ##          ##          ## "
echo -e "   ###       ###  ###    ##        #    ##  ##      ##      ##          ##   ##     ## "
echo -e "  ###         ### ###     #########    ##    ##      ########           ##    #######  "
echo -e "\033[1;34m"
echo -e "AlexAlexAleAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlex"
echo -e "AlexAlexAleAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlexAlex"
echo
echo -e "\033[1;32mCreated by Alex845"


sleep 2

# set vars
if [ ! $GITOPIA_MONIKER ]; then
	read -p "Enter node name: " GITOPIA_MONIKER
	echo 'export HID_MONIKER='$HID_MONIKER >> $HOME/.bash_profile
fi
GITOPIA_PORT=23
if [ ! $GITOPIA_WALLET ]; then
	read -p "Enter wallet name: " GITOPIA_WALLET
	echo 'export GITOPIA_WALLET='$GITOPIA_WALLET >> $HOME/.bash_profile
fi
echo "export GITOPIA_CHAIN=janus-testnet-2" >> $HOME/.bash_profile
echo "export GITOPIA_PORT=${GITOPIA_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$GITOPIA_MONIKER\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$GITOPIA_WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$GITOPIA_CHAIN\e[0m"
echo -e "Your port: \e[1m\e[32m$GITOPIA_PORT\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc mc htop tmux chrony -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.19.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME
curl https://get.gitopia.com | bash
git clone -b v1.2.0 gitopia://gitopia/gitopia
cd gitopia && make install
gitopiad version
cp $HOME/go/bin/gitopiad /usr/local/bin

# config
gitopiad config chain-id $GITOPIA_CHAIN
hid-noded config node tcp://localhost:${GITOPIA_PORT}657

# init
hid-noded init $GITOPIA_MONIKER --chain-id $GITOPIA_CHAIN

# download genesis
wget https://server.gitopia.com/raw/gitopia/testnets/master/gitopia-janus-testnet-2/genesis.json.gz
gunzip genesis.json.gz
mv genesis.json $HOME/.gitopia/config/genesis.json

# set peers and seeds
SEEDS="399d4e19186577b04c23296c4f7ecc53e61080cb@seed.gitopia.com:26656"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.gitopia/config/config.toml

# set custom ports
GITOPIA_PORT=23
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${GITOPIA_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${GITOPIA_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${GITOPIA_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${DEFUND_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${GITOPIA_PORT}660\"%" $HOME/.gitopia/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${GITOPIA_PORT}317\"%; s%^address = \":8080\"%address = \":${GITOPIA_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${GITOPIA_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${GITOPIA_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${GITOPIA_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${GITOPIA_PORT}546\"%" $HOME/.gitopia/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.gitopia/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.gitopia/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.gitopia/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.gitopia/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0utlore\"/" $HOME/.gitopia/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.gitopia/config/config.toml

# reset
gitopiad tendermint unsafe-reset-all --home $HOME/.gitopia

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/gitopiad.service > /dev/null <<EOF
[Unit]
Description=gitopia
After=network-online.target

[Service]
User=$USER
ExecStart=$(which gitopiad) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable gitopiad
sudo systemctl restart gitopiad

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u gitopiad -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${GITOPIA_PORT}657/status | jq .result.sync_info\e[0m"
