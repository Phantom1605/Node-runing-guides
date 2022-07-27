## Clone git repository and install:
```
sudo systemctl stop strided
rm -Rvf $HOME/stride
git clone https://github.com/Stride-Labs/stride.git
cd stride
git checkout 3cb77a79f74e0b797df5611674c3fbd000dfeaa1
make build
cp $HOME/stride/build/strided /usr/local/bin
```
## Update genesis:
```
wget -qO $HOME/.stride/config/genesis.json "https://raw.githubusercontent.com/Stride-Labs/testnet/main/poolparty/genesis.json"
```
## Update seed and peers:
```
SEEDS="c0b278cbfb15674e1949e7e5ae51627cb2a2d0a9@seedv2.poolparty.stridenet.co:26656"
PEERS="d6583df382d418872ab5d71d45a1a8c3d28ff269@138.201.139.175:21016,05d7b774620b7afe28bba5fa9e002b436786d4c3@195.201.165.123:20086,d28cfff8b2fe03b597f67c96814fbfd19085b7c3@168.119.124.158:26656,a9687b78c13d39d2f96ec0905c6aa201671f61f0@78.107.234.44:25656,6922feb0ca2eab2be07d60fbfd275319bcd83ec9@77.244.66.222:26656,48b1310bc81deea3eb44173c5c26873c23565d33@34.135.129.186:26656,a3afae256ad780f873f85a0c377da5c8e9c28cb2@54.219.207.30:26656,dd93bd24192d8d3151264424e44b0f213d2334dc@162.55.173.64:26656,d46c3c3de3aacb7c75bbbbf1fe5c168f0c100f26@135.181.131.116:26683,c765007c489ddbcb80249579534e63d7a00407d0@65.108.225.158:22656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.stride/config/config.toml
```

## Update node config:
```
sed -i '/STRIDE_CHAIN/d' ~/.bash_profile
echo "export STRIDE_CHAIN=STRIDE-TESTNET-2" >> $HOME/.bash_profile
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
journalctl -fu strided -o cat
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
 ## Delegate tokens to your validatir:
 ```
 strided tx staking delegate $(stride keys show $STRIDE_WALLET --bech val -a) <amountustrd> \
 --chain-id=$STRIDE_CHAIN \
 --from=$STRIDE_WALLET
 ```
