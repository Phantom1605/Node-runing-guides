Stop Hypersign and clear all uploaded blockchain data
```
sudo systemctl stop hid-noded && hid-noded tendermint unsafe-reset-all --home ~/.hid-node
```
Specify Hypersign RPC node as a variable
```
SNAP_RPC="http://95.214.52.206:26657"
```
Specify variables LATEST_HEIGHT, BLOCK_HEIGHT, TRUST_HASH
```
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash); \
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
```
Specify peer variable
```
peers="1380864bb38481fef4b2358026a5ed53fc027679@95.214.52.206:26656"
```

Add peer to `persistent_peers`
```
sed -i -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" ~/.hid-node/config/config.toml
```
Add SNAP_RPC, BLOCK_HEIGHT and TRUST_HASH in `config.toml`
```
sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" ~/.hid-node/config/config.toml
```
Restart `hypersign` and see the logs
```
sudo systemctl restart hid-noded && sudo journalctl -u hid-noded -f --no-hostname -o cat
```
