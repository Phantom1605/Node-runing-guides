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
if [ ! $NIBIRU_MONIKER ]; then
	read -p "Enter node name: " NIBIRU_MONIKER
	echo 'export NIBIRU_MONIKER='$NIBIRU_MONIKER >> $HOME/.bash_profile
fi
NIBIRU_PORT=34
if [ ! $NIBIRU_WALLET ]; then
	read -p "Enter wallet name: " NIBIRU_WALLET
	echo 'export NIBIRU_WALLET='$NIBIRU_WALLET >> $HOME/.bash_profile
fi
echo "export NOBIRU_CHAIN=nibiru-itn-1" >> $HOME/.bash_profile
echo "export NIBIRU_PORT=${NIBIRU_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NIBIRU_MONIKER\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$NIBIRU_WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$NIBIRU_CHAIN\e[0m"
echo -e "Your port: \e[1m\e[32m$NIBIRU_PORT\e[0m"
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
git clone https://github.com/NibiruChain/nibiru
cd nibiru
git checkout v0.19.2
nibid version version
cp $HOME/go/bin/nibid /usr/local/bin

# config
nibid config chain-id $NIBIRU_CHAIN
nibid config node tcp://localhost:${NIBIRU_PORT}657

# init
nibid init $NIBIRU_MONIKER --chain-id $NIBIRU_CHAIN

# download genesis
curl -s https://rpc.itn-1.nibiru.fi/genesis | jq -r .result.genesis > $HOME/.nibid/config/genesis.json

# set seeds
sed -i -e "s|seeds =.*|seeds = "'$(curl -s https://networks.itn.nibiru.fi/$NETWORK_NIBIRU/seeds)'"/" $HOME/.nibid/config/config.toml

# set custom ports
GITOPIA_PORT=34
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NIBIRU_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NIBIRU_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NIBIRU_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NIBIRU_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NIBIRU_PORT}660\"%" $HOME/.nibid/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${NIBIRU_PORT}317\"%; s%^address = \":8080\"%address = \":${NIBIRU_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${NIBIRU_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NIBIRU_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${NIBIRU_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${NIBIRU_PORT}546\"%" $HOME/.nibid/config/app.toml
# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.nibid/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.nibid/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.nibid/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.nibid/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025unibi\"/" $HOME/.nibid/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.nibid/config/config.toml

# reset
nibid tendermint unsafe-reset-all --home $HOME/.nibid

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/nibid.service > /dev/null <<EOF
[Unit]
Description=nibiru
After=network-online.target
[Service]
User=$USER
ExecStart=$(which nibid) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable nibid
sudo systemctl restart nibid

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u nibid -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${NIBIRU_PORT}657/status | jq .result.sync_info\e[0m"
