For Alerting I am using simple telegram bot from [cyberomanov](https://github.com/cyberomanov/status/tree/main/tendermint/node_status). alert you with telegram about jails and inactive status. It sends you every hour short info about your node status.

How to deploy this alerting for tendermint chains:
### 1. Create telegram bot 
It could be done via @BotFather - customize it (send to @BotFather name, username of new bot) and get a new bot and its API token. Dont forget to send message to the bot as it is not allowd to send you message first.
### 2. Create at least 2 groups: alarm and log.
Customize them, add your bot into your chats and get chats IDs:
- Write something to a channel
- Forward it to @getmyid_bot or @userinfobot
- Copy the Forwarded from chat number.
- Add bot as an channel' admin.
### 3. Connect to your server and create status folder
In the $HOME directory create a folder
```
mkdir $HOME/status/
```
### 4. Creating of `cosmos.sh` file
In this folder, `$HOME/status/`, you have to create `cosmos.sh` file with a command
```
wget -qO $HOME/status/cosmos.sh "https://raw.githubusercontent.com/cyberomanov/HaqqStatus/main/cosmos.sh"
```
You don't have to do any edits on `cosmos.sh` file, it's ready to use.

### 5. Creating of `haqq.conf`
In this folder, $HOME/status/, you have to create `haqq.conf` file

Customize it by vars. Values for it your already have:
```
MONIKER="your moniker"
DELEGATOR_ADDRESS="your wallet address"
VALIDATOR_ADDRESS="your validator address"
CHAT_ID_ALARM="your_chat_id_alarm"
CHAT_ID_STATUS="your_chat_id_status"
BOT_TOKEN="xxxxxxx:xxx-xxx_xxx this is your token"
```
Now create a haqq.conf. Copy all the command:
```
sudo tee $HOME/status/haqq.conf > /dev/null <<EOF
# /////////////////////////////////////////////////////////////////////////////////////////////////
# ////////////////// important variables for script logic, required to be filled //////////////////
# /////////////////////////////////////////////////////////////////////////////////////////////////

# validator moniker
MONIKER="$MONIKER"
# delegator address
DELEGATOR_ADDRESS="$DELEGATOR_ADDRESS"
# validator address
VALIDATOR_ADDRESS="$VALIDATOR_ADDRESS"
# token name
TOKEN="ISLM"
# token denomination (count of nulls)
DENOM=1000000000000000000
# project name, used in 'log_messages' and 'alarm_messages' for easy reading
PROJECT="haqq-testnet"
# exact full path to bin
COSMOS="/root/go/bin/haqqd"
# exact full path to config folder
CONFIG="/root/.haqqd/config/"
# 'chat_id' for 'alarm_messages' with enabled notifications
CHAT_ID_ALARM="-$CHAT_ID_ALARM"
# 'chat_id' for 'log_messages'
CHAT_ID_STATUS="-$CHAT_ID_STATUS"
# 'bot_token' for sending messages
BOT_TOKEN="$BOT_TOKEN"

# /////////////////////////////////////////////////////////////////////////////////////////////////
# /////// custom configuration, uncomment a specific variable to enable a specific function ///////
# /////////////////////////////////////////////////////////////////////////////////////////////////

# 1. link to an explorer API to get a difference between 'ideal_latest_block' and 'local_latest_block'
# 
# if validator is in the past more than 'N' blocks > 'alarm_message'
# try to find your 'curl' in 'curl.md' file or ping @cyberomanov via telegram for help
# 
# uncomment the following variable and set your value to enable the function, disabled by default
CURL="https://haqq.api.explorers.guru/api/blocks/latest"

# 2. definition of 'N'
# 
# doesn't work without correctly filled 'CURL' value
# 
# examples: 
# conditions: 'CURL' is set, 'BLOCK_GAP_ALARM' is set to '100' and 'ideal_latest_block' is 21000
# result #1: if 'local_latest_block' is 21003 > no 'alarm_message'
# result #2: if 'local_latest_block' is 20997 > no 'alarm_message'
# result #3: if 'local_latest_block' is 20895 > 'alarm_message'
# 
# uncomment the following variable and set your value to enable the function, set '0' to disable
BLOCK_GAP_ALARM=100

# -------------------------------------------------------------------------------------------------

# 3. acceptable gap between validator position and max set of active validators
# 
# examples: 
# conditions: max set is 200 active validators and 'POSITION_GAP_ALARM' is set to '10'
# result #1: if validator place is from 1st to 190th > no 'alarm_message'
# result #2: if validator place is from 191st to 200th > 'alarm_message'
# 
# uncomment the following variable and set your value to enable the function, disabled by default
POSITION_GAP_ALARM=10

# -------------------------------------------------------------------------------------------------

# 4. ignore alarm trigger when validator has inactive status
# 
# uncomment the following variable, if you want to do ignore inactive status alarm trigger
# or leave it commented, if you want to receive 'alarm_messages' about inactive status
IGNORE_INACTIVE_STATUS="true"

# 5. ignore alarm trigger when validator has wrong 'priv_validator_key'
#
# if you know that validator is running with a wrong priv_key
# than you may want to ignore 'jailed_status' and 'many_missed_blocks' trigger for 'alarm_messages'
#
# uncomment the following variable, if you want to do ignore mentioned alarm triggers
# or leave it commented, if you want to receive 'alarm_messages' about jails/missed_blocks
# IGNORE_WRONG_PRIVKEY="true"

# -------------------------------------------------------------------------------------------------

# 6. allow the script or not to allow to restart a specific service
# 
# doesn't work without correctly filled 'SERVICE' value
# 
# examples: 
# conditions #1: 'BLOCK_GAP_ALARM' is '100', 'ideal_latest_block' is 21000, 'ALLOW_SERVICE_RESTART' is 'true'
# result #1: if 'local_latest_block' is 20895 > 'alarm_message' AND 'service_restart'
# conditions #2: service is down and 'ALLOW_SERVICE_RESTART' is 'true'
# result #2: 'alarm_message' AND 'service_restart'
# conditions #3: service is up, but smth is wrong and 'ALLOW_SERVICE_RESTART' is 'true'
# result #3: 'alarm_message' AND 'service_restart'
#
# uncomment the following variable, if you want to do 'service_restart' made by the script
# or leave it commented, if you do not want to do 'service_restart' made by the script
# ALLOW_SERVICE_RESTART="true"

# 7. service name
# 
# is not used anywhere if 'ALLOW_SERVICE_RESTART' is 'false' or commented
# but used for 'service_restart' if 'ALLOW_SERVICE_RESTART' is 'true' or uncommented
# 
# uncomment the following variable and set your value to enable the function
# SERVICE="haqqd"
EOF
```
### 6. Another `name.conf` for another apps
Also you have to create as many name.conf files with nano $HOME/status/name.conf, as many nodes you have on the current server. Customize your config files. For ex: I have agoric, gravity and sifchain on the same server, so I have to create 3 files: agoric.conf, gravity.conf and sifchain.conf.

### 7. Install some packages
```
sudo apt-get install jq sysstat bc smartmontools fdisk -y
```
### 8. Chacking
Run bash `cosmos.sh` to check your settings. Normal output:
```
root@v1131623:~/status# bash cosmos.sh
 
/// 2022-07-09 11:42:37 ///
 
testnets  |  load

cpu >>>>> 68%.
ram >>>>> 47%.
part >>>> 55%.
load >>>> 14.03.
 
dws-t  |  cyberomanov

exp/me >> 955540/955540.
place >>> 88/200.
stake >>> 34.98 dws.

root@v1131623:~/status#
```
### 9. Rules for cosmos.sh
Add some rules with command
```
chmod u+x $HOME/status/cosmos.sh
```
### 10. Edit crontab with 
```
crontab -e
```
Then type this
```
# status
1,11,21,31,41,51 * * * * bash $HOME/status/cosmos.sh >> $HOME/status/cosmos.log 2>&1
```
### 11. Logs
Check your logs by commands:
```sh
cat $HOME/status/cosmos.log 
# or 
tail $HOME/status/cosmos.log -f
```

