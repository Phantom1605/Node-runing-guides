# Security
This article will provide you to setup new user, SSH key,Customize SSH Port, Disable root account, Setup Two Factor Authentication, Install Fail2ban, Configure your Firewall.
## Create a non-root user `haqq_node` with `sudo` privileges
Here we will create a non-root user with `sudo` privileges. Logins with root permissions are often overlooked as a security risk, but this is not the case! Also by logging in as a non-root user, you can avoid the issue with command `rm` that can wipe your entire server if run incorrectly by a root user.
```
sudo useradd -m -s /bin/bash haqq_node
```
Set the password for haqq_node user

```
sudo passwd haqq_node
```
Add haqq_node to the sudo group

```
sudo usermod -aG sudo haqq_node
```
Add haqq_node to the sudo group

```
sudo usermod -aG sudo haqq_node
```
## Use SSH Keys only connection
You will need to create a key pair on your local machine, with the public key stored in the `keyname` file.
```
ssh-keygen -t ed25519
```
Transfer the public key `keyname.pub` to your remote node.

```
ssh-copy-id -i $HOME/.ssh/keyname.pub haqq_node@server.public.ip.address
```
After that Login with your new haqq_node by putty or Mobaxtern and **disable root login** and **password based login**.
```
sudo nano /etc/ssh/sshd_config
```
Locate attributtes in `sshd_config`:

- `ChallengeResponseAuthentication` 
- `PasswordAuthentication`
- `PermitEmptyPasswords`
And modify their with `no` parameter

```
ChallengeResponseAuthentication no
PasswordAuthentication no
PermitEmptyPasswords no
```
And also find `PermitRootLogin` attributte. Edit it with `prohibit-password` parameter

```
PermitRootLogin prohibit-password
```
## Customize SSH Port with your custom numeric value.
Check for [possible conflicts](https://en.wikipedia.org/wiki/List\_of\_TCP\_and\_UDP\_port\_numbers) first, after that
```
Port <custom port number>
```
Then validate the syntax of your new SSH configuration using this command
```
sudo sshd -t
```
restart the SSH process
```
sudo systemctl restart sshd
```
Verify that the ssh login still works

You might need to add the `-p <port>` flag if you used a custom SSH port.
```
ssh haqq_node@server.public.ip.address -p <custom port number>
```
Connection command
```
ssh -i <path to your SSH_key_name.pub> -p <custom port number> haqq_node@server.public.ip.address
```
## Disable root account
Use sudo execute to run commands as low-level users without requiring their own privileges.
```
sudo passwd -l root
```
If you want to re-enable root use the command
```
sudo passwd -u root
```
## Setup Two Factor Authentication for SSH
Install
```
sudo apt install libpam-google-authenticator -y
```
#### Edit the /etc/pam.d/sshd file:
```
sudo nano /etc/pam.d/sshd
```
Add this line:
```
auth required pam_google_authenticator.so
```
#### Edit the /etc/ssh/sshd_config
```
sudo nano /etc/ssh/sshd_config
```
Find lines and update this attributtes with `yes`
```
ChallengeResponseAuthentication yes

UsePAM yes
```
Restart the sshd daemon using:
```
sudo systemctl restart sshd.service
```
Save the file and exit.

Execute google-authenticator command.
```
google-authenticator
```
- Make tokens “time-base”: yes
- Update the .google_authenticator file: yes
- Disallow multiple uses: yes
- Increase the original generation time limit: no
- Enable rate-limiting: yes
Now, open Google Authenticator on your phone and add your secret key to make two factor authentication work.

## Install Fail2ban
Install
```
sudo apt-get install fail2ban -y
```
Then edit a config file that monitors SSH logins.
```
sudo nano /etc/fail2ban/jail.local
```
Add a following lines to the bottom of the file.
```
[sshd]
enabled = true
port = <22 or your ssh port number>
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
# whitelisted IP addresses
ignoreip = <list of whitelisted IP address, your local daily laptop/pc>
```
- Example `ignoreip = 192.168.1.0/24 127.0.0.1/8` There is parameter accepts a list of IP addresses, IP ranges or DNS hosts that you can specify to be allowed to connect. This is where you want to specify your local machine, local IP range or local domain, separated by spaces.
- `port = <22 or your random port number>` SSh port
Save file. Restart fail2ban to take effect.
```
sudo systemctl restart fail2ban
```
## Configure your Firewall
For validator node you have to open only 26656 and ssh port.
```
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow <22 or your ssh port number>
sudo ufw allow 26656
sudo ufw enable
```
Also go to app.toml and make `enable = false` in [grpc] [grpc-web] [json-rpc] 
```
$HOME/.haqqd/config/app.toml
```







