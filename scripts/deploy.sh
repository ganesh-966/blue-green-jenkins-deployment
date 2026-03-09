#!/bin/bash

SERVER_IP=$1

echo "Deploying application to $SERVER_IP"

scp -o StrictHostKeyChecking=no -r app/* ubuntu@$SERVER_IP:/var/www/html/

ssh ubuntu@$SERVER_IP << EOF
sudo systemctl restart nginx
EOF

echo "Deployment finished"