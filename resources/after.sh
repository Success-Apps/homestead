#!/usr/bin/env bash

DYNAMODB_USER=vagrant

sudo apt-get install openjdk-11-jre-headless -y

cd /home/${DYNAMODB_USER}/
mkdir -p dynamodb
cd dynamodb

wget https://s3-ap-southeast-1.amazonaws.com/dynamodb-local-singapore/dynamodb_local_latest.tar.gz
tar -xvzf dynamodb_local_latest.tar.gz
rm dynamodb_local_latest.tar.gz

# DynamoDb script
cat >> dynamodb.sh << EOF
#!/usr/bin/env bash

cd /home/${DYNAMODB_USER}/dynamodb
nohup java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb -dbPath /home/${DYNAMODB_USER}/dynamodb --port 3000 &
EOF

chmod a+x dynamodb.sh

# DynamoDb service
cat >> dynamodb.service << EOF
[Unit]
Description="DynamoDB"

[Service]
Type=forking
ExecStart=/home/${DYNAMODB_USER}/dynamodb/dynamodb.sh

[Install]
WantedBy=multi-user.target
EOF
sudo cp /home/${DYNAMODB_USER}/dynamodb/dynamodb.service /etc/systemd/system/dynamodb.service

sudo systemctl daemon-reload
sudo systemctl enable dynamodb.service
sudo systemctl start dynamodb.service