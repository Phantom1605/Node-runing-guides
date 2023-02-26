Install Linux dependencies.
```
sudo apt-get update \
&& sudo apt-get install -y --no-install-recommends \
tzdata \
libprotobuf-dev \
ca-certificates \
build-essential \
libssl-dev \
libclang-dev \
pkg-config \
openssl \
protobuf-compiler \
git \
cmake
```
Install Rust.
 ```
 sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
rustc --version
 ```
Clone GitHub SUI repository.
```
cd $HOME
git clone https://github.com/MystenLabs/sui.git
cd sui
git remote add upstream https://github.com/MystenLabs/sui
git fetch upstream
git checkout -B testnet --track upstream/testnet
```
Create directory for SUI db and genesis.
```
mkdir $HOME/.sui
```
Download genesis file
```
wget https://github.com/MystenLabs/sui-genesis/raw/main/testnet/genesis.blob
mv genesis.blob /$HOME/.sui/
```
Make a copy of fullnode.yaml and update path to db and genesis file in it.
```
cp $HOME/sui/crates/sui-config/data/fullnode-template.yaml $HOME/.sui/fullnode.yaml
sed -i.bak "s|db-path:.*|db-path: \"$HOME\/.sui\/db\"| ; s|genesis-file-location:.*|genesis-file-location: \"$HOME\/.sui\/genesis.blob\"| ; s|127.0.0.1|0.0.0.0|" $HOME/.sui/fullnode.yaml
```
Add peers
```
sudo tee -a $HOME/.sui/fullnode.yaml  >/dev/null <<EOF

p2p-config:
  seed-peers:
   - address: "/ip4/65.109.32.171/udp/8084"
   - address: "/ip4/65.108.44.149/udp/8084"
   - address: "/ip4/95.214.54.28/udp/8080"
   - address: "/ip4/136.243.40.38/udp/8080"
   - address: "/ip4/84.46.255.11/udp/8084"
   - address: "/ip4/135.181.6.243/udp/8088"
   - address: "/ip4/89.163.132.44/udp/8080"
   - address: "/ip4/95.217.57.232/udp/8080"
   - address: "/ip4/15.204.163.225/udp/8080"
   - address: "/ip4/65.108.68.119/udp/8080"
   - address: "/ip4/155.133.22.151/udp/8080"
   - address: "/ip4/45.14.194.21/udp/8080"
   - address: "/ip4/159.69.58.44/udp/8080"
   - address: "/ip4/139.180.130.95/udp/8084"
   - address: "/ip4/51.178.73.193/udp/8084"
   - address: "/ip4/162.19.84.43/udp/8084"
   - address: "/ip4/146.59.68.207/udp/8080"
   - address: "/ip4/89.58.5.19/udp/8084"
   - address: "/ip4/38.242.227.80/udp/8080"
   - address: "/ip4/144.217.10.44/udp/8080"
   - address: "/ip4/178.18.250.62/udp/8080"
   - address: "/ip4/213.239.215.119/udp/8084"
   - address: "/dns/seoul-1.sui.nodiums.com/udp/9999"
   - address: "/dns/seoul-2.sui.nodiums.com/udp/9999"
   - address: "/dns/singapore-1.sui.nodiums.com/udp/9999"
   - address: "/dns/singapore-2.sui.nodiums.com/udp/9999"
   - address: "/dns/singapore-3.sui.nodiums.com/udp/9999"
   - address: "/dns/singapore-4.sui.nodiums.com/udp/9999"
   - address: "/dns/toronto-1.sui.nodiums.com/udp/9999"
   - address: "/dns/mumbai-1.sui.nodiums.com/udp/9999"
   - address: "/dns/los-angeles-1.sui.nodiums.com/udp/9999"
   - address: "/dns/dallas-1.sui.nodiums.com/udp/9999"
EOF
```
Build SUI binaries.
```
cargo build --release
mv ~/sui/target/release/sui-node /usr/local/bin/
mv ~/sui/target/release/sui /usr/local/bin/
sui-node -V && sui -V
```
Create Service file for SUI Node.
```
echo "[Unit]
Description=Sui Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/sui-node --config-path /$HOME/.sui/fullnode.yaml
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/suid.service


sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
```
Start SUI Full Node in Service.
```
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable suid
sudo systemctl restart suid
journalctl -u suid -f
```











