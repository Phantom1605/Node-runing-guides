## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev curl build-essential git jq ncdu bsdmainutils mc htop -y
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
cd $HOME/sei-chain
git checkout 1.1.2beta-internal
make install
cp $HOME/go/bin/seid /usr/local/bin
```
##Add variables:
```
echo 'export SEI_MONIKER="Your moniker name"'>> $HOME/.bash_profile
echo 'export SEI_WALLET="Your wallet name"'>> $HOME/.bash_profile
echo 'export SEI_CHAIN="atlantic-sub-1"' >> $HOME/.bash_profile
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
WALLET_ADDRESS=$(seid keys show $SEI_WALLET -a)
seid add-genesis-account $WALLET_ADDRESS 10000000usei
```
## Generate gentx:
```
seid gentx $SEI_WALLET 10000000usei \
--chain-id=$SEI_CHAIN \
--commission-rate=0.06 \
--commission-max-rate=0.2 \
--commission-max-change-rate=0.1 \
--pubkey=$(seid tendermint show-validator) \
--website="" \
--identity="" \
--moniker=$SEI_MONIKER
```
## Submit PR with Gentx
1. Copy the contents of $HOME/.sei/config/gentx/gentx-XXXXXXXX.json
2. Fork https://github.com/sei-protocol/testnet and create your branch 
3. Create a file {VALIDATOR_NAME}.json under the testnet/atlantic-subchains/atlantic-sub-1/gentx folder in the forked repo, paste the copied text into the file.
4. Create a Pull Request from your branch to main branch of the repository

## Await further instructions!

## Official links:

[Discord](https://discord.gg/4XD3PnhH)

[Official documentations](https://docs.seinetwork.io/nodes-and-validators/joining-testnets)

[Medium](https://medium.com/@seinetwork)

[Explorer](https://sei.explorers.guru/validators)
