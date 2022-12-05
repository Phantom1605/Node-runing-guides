## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev curl build-essential git jq ncdu bsdmainutils mc htop -y
```
## Install Go:
```
wget -O go1.18.3.linux-amd64.tar.gz https://golang.org/dl/go1.18.2.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.3.linux-amd64.tar.gz && rm go1.18.3.linux-amd64.tar.gz

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
git clone https://github.com/mars-protocol/hub.git
cd hub
git checkout v1.0.0
make install
cp $HOME/go/bin/marsd /usr/local/bin
```
## Add variables:
```
echo 'export MARS_MONIKER="Your moniker name"'>> $HOME/.bash_profile
echo 'export MARS_WALLET="Your wallet name"'>> $HOME/.bash_profile
echo 'export MARS_CHAIN="mars-1"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $MARS_MONIKER
echo $MARS_WALLET
echo $MARS_CHAIN
```
## Init:
```
marsd init $MARS_MONIKER --chain-id $MARS_CHAIN
```
## Recover or create new wallet:
* create new wallet:
```
marsd keys add $MARS_WALLET
```
* recover existing wallet:
```
marsd keys add $MARS_WALLET --recover
```
## Add genesis account:
```
WALLET_ADDRESS=$(marsd keys show $MARS_WALLET -a)
marsd add-genesis-account $WALLET_ADDRESS 1000000umars
```
## Generate gentx:
```
marsd gentx $MARS_WALLET 1000000umars \
--moniker=$MARS_MONIKER \
--chain-id=$MARS_CHAIN \
--commission-rate=0.06 \
--commission-max-rate=1.0 \
--commission-max-change-rate=0.01 \
--pubkey=$(marsd tendermint show-validator) \
--website="" \
--identity="" \
--min-self-delegation=1

```
## Submit PR with Gentx
1. Copy the contents of $HOME/.sei/config/gentx/gentx-XXXXXXXX.json
2. Fork https://github.com/mars-protocol/networks and create your branch 
3. Create a file gentx-<VALIDATOR_NAME>.json under the mars-1/gentxs folder in the forked repo, paste the copied text into the file.
4. Create a Pull Request from your branch to main branch of the repository

## Await further instructions!

## Official links:

[Discord](https://discord.gg/marsprotocol)

[Official Website](https://marsprotocol.io/)

[Github](https://github.com/mars-protocol/networks)
