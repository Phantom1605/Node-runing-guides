## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```
## Install Go:
```
wget -O go1.18.3.linux-amd64.tar.gz https://golang.org/dl/go1.18.3.linux-amd64.tar.gz
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
git clone https://github.com/empowerchain/empowerchain
cd empowerchain/chain
make install
cp $HOME/go/bin/empowerchaind /usr/local/bin
```
## Add variables:
```
echo 'export EMPOWER_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export EMPOWER_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export EMPOWER_CHAIN="altruistic-1"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $EMPOWER_MONIKER
echo $EMPOWER_WALLET
echo $EMPOWER_CHAIN
```
## Init:
```
empowerd init $EMPOWER_MONIKER --chain-id $EMPOWER_CHAIN
```
## Recover or create new wallet:
* create new wallet:
```
empowerd keys add $EMPOWER_WALLET
```
* recover existing wallet:
```
empowerd keys add $EMPOWER_WALLET --recover
```
## Add genesis account:
```
WALLET_ADDRESS=$(empowerd keys show $EMPOWER_WALLET -a)
empowerd add-genesis-account $WALLET_ADDRESS 1000000umpwr
```
## Generate gentx:
```
empowerd gentx $EMPOWER_WALLET 1000000umpwr \
 --chain-id=$EMPOWER_CHAIN \
 --moniker=$EMPOWER_MONIKER \
 --min-self-delegation=1 \
 --commission-rate=0.06 \
 --commission-max-rate=0.2 \
 --commission-max-change-rate=0.1 \
 --pubkey=$(empowerd tendermint show-validator) \
 --website="" \
 --identity=""
```
## Submit PR with Gentx
1. Copy the contents of ${HOME}/.stateset/config/gentx/gentx-XXXXXXXX.json.
2. Fork https://github.com/empowerchain/empowerchain  and create your branch
3. Create a file gentx-<VALIDATOR_NAME>.json under the empowerchain/testnets/altruistic-1/ folder in the forked repo, paste the copied text into the file.
4. Create a Pull Request from your branch to main branch of the repository
5. Await further instructions!
