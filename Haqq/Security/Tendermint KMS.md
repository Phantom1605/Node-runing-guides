### Set up a Key Management System for Haqq
## Prepare TMKMS
```bash
# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
# GCC
sudo apt update
sudo apt install git build-essential ufw curl jq snapd --yes
# Libusb
apt install libusb-1.0-0-dev
# If on x86_64 architecture:
echo "export RUSTFLAGS=-Ctarget-feature=+aes,+ssse3" >> $HOME/.bash_profile
source $HOME/.bash_profile
```
We will be using tmkms with the `--features=softsign` flag
```
cd $HOME
git clone https://github.com/iqlusioninc/tmkms.git
cd $HOME/tmkms
cargo install tmkms --features=softsign
tmkms init config
tmkms softsign keygen ./config/secrets/secret_connection_key
```
Now we should transfer your validator private key from your validator to your VM running TMKMS (ip of validator: XXX.XXX.XXX.XXX):
```sh
scp -p <custom port number> root@XXX.XXX.XXX.XXX:~/.haqqd/config/priv_validator_key.json ~/.tmkms/haqq

# If you are using ssh key then:
scp -p <custom port number> -i <path to your SSH_key_name.pub> root@XXX.XXX.XXX.XXX:~/.haqqd/config/priv_validator_key.json ~/tmkms/config/secrets
```
Now, import the private validator key into tmkms:
```
tmkms softsign import $HOME/tmkms/config/secrets/priv_validator_key.json $HOME/tmkms/config/secrets/priv_validator_key
```
Now backup and delete `priv_validator_key.json` from both servers.

### Modify the tmkms.toml file
```
nano $HOME/tmkms/config/tmkms.toml
```
There are required lines
```sh
# Tendermint KMS configuration file

## Chain Configuration

### Cosmos Hub Network

[[chain]]
id = "haqq_53211-3"
key_format = { type = "cosmos-json", account_key_prefix = "haqqpub", consensus_key_prefix = "haqqvalconspub" }
state_file = "/root/tmkms/config/state/priv_validator_state.json"

## Signing Provider Configuration

### Software-based Signer Configuration

[[providers.softsign]]
chain_ids = ["haqq_53211-3"]
key_type = "consensus"
path = "/root/tmkms/config/secrets/priv_validator_key"

## Validator Configuration

[[validator]]
chain_id = "haqq_53211-3"
addr = "tcp://XXX.XXX.XXX.XXX:26658" # your validator node ip and port
secret_key = "/root/tmkms/config/secrets/secret_connection_key"
protocol_version = "v0.34"
reconnect = true
```
### Modify your validators `config.toml` to use the port you selected in the tmkms.toml file:
```
nano $HOME/.haqqd/config/config.toml
```
This line is required, where 26658 is your ABCI application port
```
priv_validator_laddr = "tcp://0.0.0.0:26658"
```
Comment out the `priv_validator_key_file` line and the `priv_validator_state_file` line:
```
# Path to the JSON file containing the private key to use as a validator in the consensus protocol
# priv_validator_key_file = "config/priv_validator_key.json"

# Path to the JSON file containing the last sign state of a validator
# priv_validator_state_file = "data/priv_validator_state.json"
```
### On your server running TMKMS - start it:
```sh
sudo tee <<EOF >/dev/null /etc/systemd/system/tmkms.service
[Unit]  
Description=tmkms Haqq Network service  
After=network.target  
StartLimitIntervalSec=0

[Service]
Type=simple  
Restart=always  
RestartSec=10  
User=root
ExecStart=/usr/bin/tmkms start -c $HOME/.tmkms/haqq/tmkms.toml  
LimitNOFILE=1024

[Install]  
WantedBy=multi-user.target
EOF

# Start tmkms
sudo systemctl enable tmkms
sudo systemctl daemon-reload
sudo systemctl restart tmkms
journalctl -u tmkms -f
```
### On your server running HAQQ - restart it:
```
sudo systemctl restart haqqd && journalctl -u haqqd -f --output cat
```



