Instruction from Cosmos forum: https://forum.cosmos.network/t/sentry-node-architecture-overview/454

For more protection, we definitely need a sentry node. I wrote a small guide with full instructions on how to install sentry and connect your node to it.

We need a new VPS server. There will be list of the commands to install. Let’s install sentry node for our Haqq validator.

I will not repeat the guide to installing the Haqq, I will just note what needs to be done get senrty node from standart rpc public node.
So, let’s install a new Haqq node first: https://github.com/Phantom1605/Node-runing-guides/blob/main/Haqq/Haqq_Testnet.md

Follow these steps: Install Node.js, Install Go, Install Haqq. Configure your node, init with new moniker, I choose “sentry”. Start your node and wait when it’ll be synced.
After your new node has synchronized, we will make the necessary settings.

## 1. Editing the `config.toml` file
```
nano $HOME/.haqqd/config/config.toml
```
And make changes as you see here:

![image](https://user-images.githubusercontent.com/85427001/196041306-a5338b59-54b3-4ed1-8dbf-0b0dd2fac4e9.png)

- `validator node, optionally other sentry nodes` type in this way: `node_id1@ip1:26656,node_id2@ip2:26656`
- `validator node id` type in this way: `node_id@ip:26656`
- To find out the id node of the validator node, run the following command in the terminal: `haqqd status 2>&1 | jq`
Afte the command below you will find your id node of Sentry node. and copy it in that way (here is mine):
```
sdgf87dfhlk45ljhk2g3k2g34kdfsaldkjfsd9sd@49.21.623.83:26656
```
## 2. You also need to configure the `config.toml` file for the validator node, as follows:

![image](https://user-images.githubusercontent.com/85427001/196041419-1bc0065d-bea6-4d75-bc7b-3870acd36eef.png)

- `list of sentry nodes` type in this way: `node_id1@ip1:26656,node_id2@ip2:26656`

### Configure the firewall.
For sentry node:
```
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 26656
sudo ufw allow 26657
sudo ufw enable
```
For validator node:
```
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow from <SENTRY'S IP ADDRESS> to any port 26656
sudo ufw enable
```
### Resart both of your nodes.
```sh
# restart
sudo systemctl restart haqqd
# logs
sudo journalctl -u haqqd -f -o cat
haqqd status 2>&1 | jq
```












