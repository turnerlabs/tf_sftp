#!/usr/bin/bash -x

set -e

sudo apt-get -y update

sudo apt-get -y install python
echo "installed python"

sudo apt-get -y install python3.5
echo "installed python3"

sudo apt-get -y install unzip
echo "installed unzip"

curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
echo "pull down awscli"

unzip awscli-bundle.zip

sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

rm awscli-bundle.zip
rm -rf awscli-bundle/
echo "installed awscli"

SSHD_CONFIG="$S3_BUCKET/sshd_config"

/usr/local/bin/aws s3 cp $SSHD_CONFIG /home/ubuntu/sshd_config
sudo cp /home/ubuntu/sshd_config /etc/ssh/sshd_config
sudo service ssh restart
rm /home/ubuntu/sshd_config
echo "updated ssh and sshd_config"

sudo mkdir -p /home/sftpusers/home
sudo chown root:root /home/sftpusers
sudo chown root:root /home/sftpusers/home
echo "added sftpuser directories and set appropriate privileges"

sudo groupadd sftpgroup
echo "added sftpgroup"

sudo useradd -g sftpgroup -s /bin/false sftpuser
echo "added sftpuser"

USERPASS="sftpuser:$SFTPUSER_PASSWORD"

echo $USERPASS | sudo chpasswd
echo "updated sftpuser password"

sudo mkdir /home/sftpusers/home/sftpuser
sudo chown sftpuser:sftpgroup /home/sftpusers/home/sftpuser
sudo chmod 750 /home/sftpusers/home/sftpuser
echo "added sftpuser directory and set appropriate privileges"

CPS3_SCRIPT="$S3_BUCKET/cps3.sh"
/usr/local/bin/aws s3 cp $CPS3_SCRIPT /home/ubuntu/cps3.sh
chmod 700 /home/ubuntu/cps3.sh

mkdir -p /home/ubuntu/logs

crontab -l | { cat; echo "* * * * * /home/ubuntu/cps3.sh > /home/ubuntu/logs/cron.log 2>&1"; } | crontab -