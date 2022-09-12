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
git clone https://github.com/hypersign-protocol/hid-node.git
cd $HOME/hid-node
make install
cp $HOME/go/bin/hid-noded /usr/local/bin
hid-noded version
```
## Add variables:
```
echo 'export HID_MONIKER="Alex845"'>> $HOME/.bash_profile
echo 'export HID_WALLET="Alex845W"'>> $HOME/.bash_profile
echo 'export HID_CHAIN="jagrat"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $HID_MONIKER
echo $HID_WALLET
echo $HID_CHAIN
```
## Init:
```
hid-noded init $HID_MONIKER --chain-id $HID_CHAIN
```

## Create new wallet:
```
hid-noded keys add $HID_WALLET
```
## Add genesis account:
```
WALLET_ADDRESS=$(hid-noded keys show $HID_WALLET -a)
hid-noded add-genesis-account $WALLET_ADDRESS 100000000000uhid
```
## Generate gentx:
```
hid-noded gentx $HID_WALLET 100000000000uhid \
--chain-id=$HID_CHAIN \
--commission-rate=0.06 \
--commission-max-rate=1.0 \
--commission-max-change-rate=0.01 \
--min-self-delegation=100000000000 \
--website=https://github.com/Phantom1605 \
--identity=2AD69C289965C63D \
--moniker=$HID_MONIKER
```

## Submit PR with Gentx
* Copy the contents of ${HOME}/.hid-noded/config/gentx/gentx-XXXXXXXX.json.
* Fork https://github.com/hypersign-protocol/networks
* Create a file gentx-<VALIDATOR_NAME>.json under the testnet/jagrat/gentxs/ folder in the forked repo, paste the copied text into the file.
* Create a Pull Request to the main branch of the repository
* Await further instructions!
