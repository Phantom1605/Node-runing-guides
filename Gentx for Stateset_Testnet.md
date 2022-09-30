## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev libleveldb-dev jq build-essential gcc git make ncdu htop nano mc chrony -y
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
## Install starport:
```
curl https://get.starport.network/starport! | bash
```
## Clone git repository and install:
```
cd $HOME
git clone https://github.com/stateset/core
cd core
starport chain build
```
## Add variables:
```
echo 'export STATESET_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export STATESET_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export STATESET_CHAIN="stateset-1-testnet"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $STATESET_MONIKER
echo $STATESET_WALLET
echo $STATESET_CHAIN
```
## Init:
```
statesetd init $STATESET_MONIKER --chain-id $STATESET_CHAIN
```
## Recover or create new wallet:
* create new wallet:
```
statesetd keys add $STATESET_WALLET
```
* recover existing wallet:
```
statesetd keys add $STATESET_WALLET --recover
```
## Add genesis account:
```
WALLET_ADDRESS=$(statesetd keys show $STATESET_WALLET -a)
statesetd add-genesis-account $WALLET_ADDRESS 10000000000ustate
```
## Generate gentx:
```
statesetd gentx $STATESET_WALLET 9000000000ustate \
--chain-id=$STATESET_CHAIN \
--min-self-delegation=100000000000 \
--commission-rate=0.06 \
--commission-max-rate=1.0 \
--commission-max-change-rate=0.01 \
--pubkey=$(statesetd tendermint show-validator) \
--website="" \
--identity="" \
--moniker=$STATESET_MONIKER
```
## Submit PR with Gentx
1. Copy the contents of ${HOME}/.stateset/config/gentx/gentx-XXXXXXXX.json.
2. Fork https://github.com/stateset/networks and create your branch
3. Create a file gentx-<VALIDATOR_NAME>.json under the testnets/stateset-1-testnet/gentx/ folder in the forked repo, paste the copied text into the file.
4. Create a Pull Request from your branch to main branch of the repository
## Await further instructions!
