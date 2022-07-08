## Install dependencies:
```cd $HOME
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils -y
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
## Add genesis account:
```
seid add-genesis-account $SEI_WALLET 10000000usei
```
## Generate gentx:
```
quicksilverd gentx $SEI_WALLET 10000000usei \
--chain-id=$SEI_CHAIN \
--commission-rate=0.08 \
--commission-max-rate=0.2 \
--commission-max-change-rate=0.1 \
--pubkey=$(seid tendermint show-validator) \
--website="" \
--identity="" \
--moniker=$SEI_MONIKER
```
## Submit PR with Gentx:
* Copy the contents of $HOME/.sei/config/gentx/gentx-XXXXXXXX.json
* Fork https://github.com/sei-protocol/testnet
* Create a file gentx-{VALIDATOR_NAME}.json under the testnet/sei-incentivized-testnet/gentx folder in the forked repo, paste the copied text into the file.
* Create a Pull Request to the main branch of the repository

## Official links:
[Official Docs](https://docs.seinetwork.io/nodes-and-validators/seinami-incentivized-testnet)

[Discord](https://discord.gg/KPUTFzWYQC)

