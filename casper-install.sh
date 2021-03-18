# Tested on Ubuntu 20.04
# Preps

sudo apt update
sleep 1
sudo apt-get update
sleep 3
sudo apt install dnsutils -y
sleep 3
sudo apt install jq -y
sleep 3
sudo apt install mc -y
sleep 3
sudo apt install tmux -y
sleep 3
sudo apt install git -y
sleep 3

# Compile contracts

cd ~

sudo apt purge --auto-remove cmake
sleep 1
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
sleep 1
sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ focal main'  
sleep 1 
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
sleep 1

sudo apt install libssl-dev -y
sleep 1
sudo apt install pkg-config -y
sleep 1
sudo apt install build-essential -y
sleep 1

cd ~

git clone https://github.com/CasperLabs/casper-node.git
sleep 3
cd casper-node
sleep 3
git fetch
sleep 3
git checkout release-0.7.6 
sleep 3
make setup-rs && make build-client-contracts -j
sleep 3


# Stop Casper


sudo systemctl stop casper-node
sleep 1
sudo systemctl stop casper-node-launcher
sleep 1

cd ~

sudo apt remove -y casper-node 
sleep 1
sudo apt remove -y casper-client 
sleep 1
sudo apt remove -y casper-node-launcher
sleep 1


# Clean up old genesis file location

sudo rm /etc/casper/config.*
sleep 1
sudo rm /etc/casper/accounts.csv 
sleep 1
sudo rm /etc/casper/chainspec.toml 
sleep 1
sudo rm /etc/casper/validation.md5
sleep 1
curl -JLO https://bintray.com/casperlabs/debian/download_file?file_path=casper-node-launcher_0.2.0-0_amd64.deb
sleep 3
curl -JLO https://bintray.com/casperlabs/debian/download_file?file_path=casper-client_0.7.6-0_amd64.deb
sleep 3
sudo dpkg -i ./casper-client_0.7.6-0_amd64.deb ./casper-node-launcher_0.2.0-0_amd64.deb
sleep 3
cd /etc/casper
sleep 1
sudo -u casper ./pull_casper_node_version.sh 1_0_0
sleep 1

# Get useful scripts

cd ~
curl -JLO https://raw.githubusercontent.com/matsuro-hadouken/casper-tools/master/balance_check.sh
sleep 3
curl -JLO https://raw.githubusercontent.com/matsuro-hadouken/casper-tools/master/bond.sh
sleep 3
wget https://raw.githubusercontent.com/matsuro-hadouken/casper-tools/master/explorer.sh
sleep 3
wget https://raw.githubusercontent.com/matsuro-hadouken/casper-tools/master/active_validators.sh
sleep 1
chmod 755 balance_check.sh
sleep 1
chmod 755 bond.sh
sleep 1
chmod 755 active_validators.sh
sleep 1
chmod 755 explorer.sh


# Create node keys


cd /etc/casper/validator_keys
sleep 3
sudo casper-client keygen .
sleep 3
cat /etc/casper/validator_keys/public_key_hex
sleep 5


# Set trusted hash into config.toml

sudo sed -i "/trusted_hash =/c\trusted_hash = '$(curl -s 18.144.176.168:8888/status | jq -r .last_added_block_info.hash | tr -d '\n')'" /etc/casper/1_0_0/config.toml

sudo logrotate -f /etc/logrotate.d/casper-node
sleep 1
sudo /etc/casper/delete_local_db.sh
sleep 1
sudo systemctl start casper-node-launcher
sleep 1
systemctl status casper-node-launcher
sleep 1
cat /etc/casper/validator_keys/public_key_hex


