## Install dependencies:

```
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils -y < "/dev/null"
```
## Install Go:
```
cd $HOME
wget -O go1.17.3.linux-amd64.tar.gz https://golang.org/dl/go1.17.3.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.3.linux-amd64.tar.gz && rm go1.17.3.linux-amd64.tar.gz
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
cd $HOME && git clone --branch public-testnet-v2 https://github.com/stafihub/stafihub
```


## Install:
```
cd $HOME/stafihub && make install
cp $HOME/go/bin/stafihubd /usr/local/bin
```

## Add your moniker instead of <Your_Moniker>. Enter by one command.
```
NODE_MONIKER=<Your_Moniker> ; \
echo $NODE_MONIKER ; \
echo 'export NODE_MONIKER='\"${NODE_MONIKER}\" >> $HOME/.bash_profile
```


## Add your wallet name instead of <Your_Wallet_Name>. Enter by one command.
```
YOUR_TEST_WALLET=<Your_Wallet_Name> ; \
echo $YOUR_TEST_WALLET ; \
echo 'export YOUR_TEST_WALLET='\"${YOUR_TEST_WALLET}\" >> $HOME/.bash_profile
```
## Add CHAIN_ID. Enter by one command.
```
CHAIN_ID=stafihub-public-testnet-2 ; \
echo $CHAIN_ID ; \
echo 'export CHAIN_ID='\"${CHAIN_ID}\" >> $HOME/.bash_profile
```

## Generate keys:
```
stafihubd keys add $YOUR_TEST_WALLET
```

## Init:
```
stafihub init $NODE_MONIKER --chain-id $CHAIN_ID --recover
```

## Download genesis:
```
wget -O $HOME/.stafihub/config/genesis.json "https://raw.githubusercontent.com/stafihub/network/main/testnets/stafihub-public-testnet-2/genesis.json"
```

## Unsafe restart all:
```
stafihubd tendermint unsafe-reset-all --home ~/.stafihub
```

## Configure your node:
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.01ufis\"/" $HOME/.stafihub/config/app.toml
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.stafihub/config/app.toml
peers="4e2441c0a4663141bb6b2d0ea4bc3284171994b6@46.38.241.169:26656,79ffbd983ab6d47c270444f517edd37049ae4937@23.88.114.52:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.stafihub/config/config.toml
```

 ## Install service to run the node:
 ```
sudo tee <<EOF >/dev/null /etc/systemd/system/stafihubd.service
[Unit]
Description=StaFiHub Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which stafihubd) start --log_level=info
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable stafihubd
sudo systemctl restart stafihubd
```
## Check your node logs:
```
journalctl -u stafihubd -f
```

## Status of sinchronization:
```
stafihubd status 2>&1 | jq .SyncInfo
```


## Faucet:
You can ask for tokens in the #faucet Discord channel.
!faucet send YOUR_WALLET_ADDRESS

## Сheck your balance:
```
stafihubd q bank balances <stafi...your..wallet...>
```

## Create validator:
```
stafihubd tx staking create-validator \
--amount=1000000ufis \
 --pubkey=$(stafihubd tendermint show-validator) /
 --from=$YOUR_TEST_WALLET \
 --moniker=$NODE_MONIKER \
 --chain-id=$CHAIN_ID \
 --details="" \
 --website=""\
 --identity= ""\
 --commission-rate=0.1 \
 --commission-max-rate=0.2 \
 --commission-max-change-rate=0.01 \ 
 --min-self-delegation=1 \
 --gas-prices=0.025ufis
 ```

## Delegate tokens to your validator:
```
stafihubd tx staking delegate $(stafihubd keys show $YOUR_TEST_WALLET --bech val -a) <amountufis> \
--chain-id=$CHAIN_ID \
--from=$YOUR_TEST_WALLET \
--gas auto \
--fees=200ufis
```

## Collect rewards:
```
stafihubd tx distribution withdraw-all-rewards --from $YOUR_TEST_WALLET --fees=300ufis --chain-id $CHAIN_ID
```

## Unjail:
```
stafihubd tx slashing unjail --chain-id $CHAIN_ID --from $YOUR_TEST_WALLET --gas=auto --fees=1000ufis
```

## Stop the node:
```
sudo systemctl stop stafihubd
```

## Delete node files and directories:
```
rm -Rvf $HOME/stafihub
rm -Rvf $HOME/.stafihub
```
