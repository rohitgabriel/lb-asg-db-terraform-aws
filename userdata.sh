#!/bin/bash
apt-get update -y
snap install --classic go
apt-get install jq -y
cp /snap/bin/go /usr/local/bin/
apt-get install go-dep -y
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
apt install unzip -y
unzip awscliv2.zip
./aws/install
aws s3 cp s3://eittestappbucket1/dist ~/application --recursive
cd ~/application
chmod 755 ./TechTestApp
sed -i '/ListenHost/c\"ListenHost" = "0.0.0.0"' conf.toml
aws rds describe-db-instances --db-instance-identifier testapp-postgres > /tmp/dbdetails.txt
x=$(aws rds describe-db-instances --db-instance-identifier testapp-postgres| jq '.DBInstances[0].Endpoint.Address')
sed -i "s/\"localhost\"/$x/g" conf.toml
sed -i "s/changeme/postgresdb/g" conf.toml
./TechTestApp updatedb -s
./TechTestApp serve