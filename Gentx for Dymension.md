## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt-get install nano mc git gcc g++ make curl yarn -y
```

## install Go:
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
## Clone git repository:
```
cd $HOME 
git clone https://github.com/dymensionxyz/dymension.git --branch v0.2.0-beta
cd dymension
make install
cp $HOME/go/bin/dymd /usr/local/bin
dymd version --long
```
## Add variables:
```
echo 'export DYMENSION_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export DYMENSION_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export DYMENSION_CHAIN="35-C"' >> $HOME/.bash_profile
# for the mainnet use mainnet-1 chain
. $HOME/.bash_profile

#let's check
echo $DYMENSION_MONIKER
echo $DYMENSION_WALLET
echo $DYMENSION_CHAIN
```
## Init:
```
dymd init $DYMENSION_MONIKER --chain-id $DYMENSION_CHAIN
```
## Recover or create new wallet:
* create new wallet:
```
dymd keys add $DYMENSION_WALLET
```
* recover existing wallet:
```
dymd keys add $DYMENSION_WALLET --recover
```
## Add genesis account:
```
WALLET_ADDRESS=$(dymd keys show $DYMENSION_WALLET -a)
dymd add-genesis-account $WALLET_ADDRESS 600000000000udym
```
## Generate gentx:
```
dymd gentx $DYMENSION_WALLET 500000000000udym \
--chain-id=$DYMENSION_CHAIN \
--commission-rate=0.06 \
--commission-max-rate=0.2 \
--commission-max-change-rate=0.1 \
--pubkey=$(dymd tendermint show-validator) \
--website="" \
--identity="" \
--moniker=$DYMENSION_MONIKER
```
## Submit PR with Gentx
1. Copy the contents of $HOME/.dymension/config/gentx/gentx-XXXXXXXX.json
2. Fork https://github.com/dymensionXYZ/testnets/
3. Create a file {VALIDATOR_NAME}.json under the dymension-hub/35-C/gentx folder in the forked repo, paste the copied text into the file.
4. Create a Pull Request from your branch to main branch of the repository

## Await further instructions!

## Official links:

[Discord](https://discord.gg/dymension)

[Official documentations](https://docs.dymension.xyz/developers/getting-started/run-a-node/)

[Official site](https://dymension.xyz/)

[Github](https://github.com/dymensionxyz)
