## Install dependencies:
```
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
git clone https://github.com/aura-nw/aura
cd aura
git checkout euphoria
make install
cp $HOME/go/bin/aurad /usr/local/bin
```

## Add variables:
```
echo 'export AURA_MONIKER="Your Moniker name"'>> $HOME/.bash_profile
echo 'export AURA_WALLET="Your Wallet name"'>> $HOME/.bash_profile
echo 'export AURA_CHAIN="euphoria-1"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $AURA_MONIKER
echo $AURA_WALLET
echo $AURA_CHAIN
```
## Init:
```
aurad init $AURA_MONIKER --chain-id $AURA_CHAIN
```

## Recover or create new wallet:
* create new wallet:
```
aurad keys add $AURA_WALLET
```
* recover existing wallet:
```
aurad keys add $AURA_WALLET --recover
```

## Add genesis account:
```
WALLET_ADDRESS=$(aurad keys show $AURA_WALLET -a)
aurad add-genesis-account $WALLET_ADDRESS 3600000000ueaura
```
## Generate gentx:
```
aurad gentx $AURA_WALLET 3600000000ueaura \
--chain-id=$AURA_CHAIN \
--commission-rate=0.08 \
--commission-max-rate=0.2 \
--commission-max-change-rate=0.1 \
--pubkey=$(aurad tendermint show-validator) \
--website="" \
--identity="" \
--moniker=$AURA_MONIKER
```
## Submit PR with Gentx
* Copy the contents of $HOME/.aura/config/gentx/gentx-XXXXXXXX.json
* Fork https://github.com/aura-nw/testnets
* Create a file gentx-{VALIDATOR_NAME}.json under the testnets/euphoria-1/gentx folder in the forked repo, paste the copied text into the file.
* Upload your logo file into {VALOPER_ADDRESS}.png under the testnets/euphoria-1/logo folder.
* Create a Pull Request to the main branch of the repository

## Official links:
[Official docs](https://github.com/aura-nw/testnets/blob/main/euphoria-1/pre-lauch-setup.md)
