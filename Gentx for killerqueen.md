## Install dependencies:
```
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils htop -y < "/dev/null" -y
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
git clone https://github.com/ingenuity-build/quicksilver.git --branch v0.3.0
cd quicksilver
make build
cp $HOME/quicksilver/build/quicksilverd /usr/local/bin
quicksilverd version
```
## Add variables:
```
echo 'export QUICKSILVER_MONIKER="Your moniker"'>> $HOME/.bash_profile
echo 'export QUICKSILVER_WALLET="Your wallet name"'>> $HOME/.bash_profile
echo 'export QUICKSILVER_CHAIN="killerqueen-1"' >> $HOME/.bash_profile
. $HOME/.bash_profile

# let's check
echo $QUICKSILVER_MONIKER
echo $QUICKSILVER_WALLET
echo $QUICKSILVER_CHAIN
```
## Init:
```
quicksilverd init $QUICKSILVER_MONIKER --chain-id $QUICKSILVER_CHAIN
```
## Generate keys:
```
# if you already have a wallet:
quicksilverd keys add $QUICKSILVER_WALLET --recover
```
## Add genesis accaunt:
```
quicksilverd add-genesis-account $QUICKSILVER_WALLET 100000000uqck

quicksilverd gentx $QUICKSILVER_WALLET 100000000uqck \
--chain-id=QUICKSILVER_CHAIN \
--commission-rate=0.08 \
--commission-max-rate=0.2 \
--commission-max-change-rate=0.1 \
--pubkey=$(quicksilverd tendermint show-validator) \
--website="" \
--identity="" \
--moniker=$QUICKSILVER_MONIKER
```
