## Clone git repository and install:
```
sudo systemctl stop strided
rm -Rvf $HOME/stride
git clone https://github.com/Stride-Labs/stride.git
cd stride
git checkout cf4e7f2d4ffe2002997428dbb1c530614b85df1b
make build
cp $HOME/stride/build/strided /usr/local/bin
```
## Update genesis:
```
wget -qO $HOME/.stride/config/genesis.json "https://raw.githubusercontent.com/Stride-Labs/testnet/main/poolparty/genesis.json"
```
## Update seed and peers:
```
SEEDS="d2ec8f968e7977311965c1dbef21647369327a29@seedv2.poolparty.stridenet.co:26656"
PEERS="2771ec2eeac9224058d8075b21ad045711fe0ef0@34.135.129.186:26656,a3afae256ad780f873f85a0c377da5c8e9c28cb2@54.219.207.30:26656,328d459d21f82c759dda88b97ad56835c949d433@78.47.222.208:26639,bf57701e5e8a19c40a5135405d6757e5f0f9e6a3@143.244.186.222:16656,f93ce5616f45d6c20d061302519a5c2420e3475d@135.125.5.31:54356"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.stride/config/config.toml
```

## Update node config:
```
sed -i '/STRIDE_CHAIN/d' ~/.bash_profile
echo "export STRIDE_CHAIN=STRIDE-TESTNET-4" >> $HOME/.bash_profile
source $HOME/.bash_profile
strided config chain-id $STRIDE_CHAIN
```
## Unsafe reset all:
```
strided tendermint unsafe-reset-all --home $HOME/.stride
```
## Start service:
```
sudo systemctl start strided
journalctl -u strided -f --output cat
```
## Check your balance:
```
strided q bank balances $(strided keys show $STRIDE_WALLET -a)
```
## Create a validator:
```
strided tx staking create-validator \
 --amount=10000000ustrd \
 --pubkey=$(strided tendermint show-validator) \
 --from=$STRIDE_WALLET \
 --moniker=$STRIDE_MONIKER \
 --chain-id=$STRIDE_CHAIN \
 --details="" \
 --website="" \
 --identity="" \
 --commission-rate=0.08 \
 --commission-max-rate=0.2 \
 --commission-max-change-rate=0.01 \
 --min-self-delegation=1
 ```
 ## Check your node status:
 ```
 curl localhost:26657/status | jq
 ```
 ## Delegate tokens to your validatir:
 ```
 strided tx staking delegate $(strided keys show $STRIDE_WALLET --bech val -a) <amountustrd> \
  --chain-id=$STRIDE_CHAIN \
  --from=$STRIDE_WALLET
 ```
 ## Unjail:
 ```
strided tx slashing unjail \
  --chain-id $STRIDE_CHAIN \
  --from $STRIDE_WALLET
 ```
 ## Official links:
 
[Discord](http://stride.zone/discord)

[Github](https://github.com/Stride-Labs/testnet)

[Exploree](https://stride.explorers.guru/validators)
