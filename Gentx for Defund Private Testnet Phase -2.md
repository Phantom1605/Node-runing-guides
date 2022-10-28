## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev curl build-essential git jq ncdu bsdmainutils mc htop -y
```
## Install Go:
```
wget -O go1.18.2.linux-amd64.tar.gz https://golang.org/dl/go1.19.1.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.1linux-amd64.tar.gz && rm go1.19.1linux-amd64.tar.gz

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
git clone https://github.com/defund-labs/defund.git
cd defund
git checkout v0.1.0-alpha
make install
cp $HOME/go/bin/defundd /usr/local/bin
```
## Add variables:
```
echo 'export DEFUND_MONIKER="your node moniker"'>> $HOME/.bash_profile
echo 'export DEFUND_WALLET="your wallet name"'>> $HOME/.bash_profile
echo 'export DEFUND_CHAIN="defund-private-2"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $DEFUND_MONIKER
echo $DEFUND_WALLET
echo $DEFUND_CHAIN
```
## Init:
```
defundd init $DEFUND_MONIKER --chain-id $DEFUND_CHAIN
```

## Create new wallet:
```
defundd keys add $DEFUND_WALLET
```
## Add genesis account:
```
WALLET_ADDRESS=$(hid-noded keys show $DEFUND_WALLET -a)
hid-noded add-genesis-account $WALLET_ADDRESS 100000000ufetf
```
## Generate gentx:
```
defundd gentx $DEFUND_WALLET 90000000ufetf \
--chain-id=$DEFUND_CHAIN \
--commission-rate=0.06 \
--commission-max-rate=0.2 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--website="your website" \
--identity="your identity" \
--moniker=$DEFUND_MONIKER
```

## Submit PR with Gentx
* Copy the contents of ${HOME}/.hid-noded/config/gentx/gentx-XXXXXXXX.json.
* Fork Fork https://github.com/defund-labs/testnet and create your branch
* Create a file gentx-VALIDATOR_NAME.json under the defund-private-2/gentx folder in the forked repo, paste the copied text into the file.
* Create a Pull Request to the main branch of the repository
* Await further instructions!
