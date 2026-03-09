#!/bin/bash
set -e

SERVER_IP=$1
KEY=/var/lib/jenkins/bluegreen.pem

echo "Deploying application to $SERVER_IP"

scp -i $KEY -o StrictHostKeyChecking=no app/index.html ubuntu@$SERVER_IP:/tmp/

ssh -i $KEY -o StrictHostKeyChecking=no ubuntu@$SERVER_IP << EOF
sudo mv /tmp/index.html /var/www/html/index.html
sudo systemctl restart nginx
EOF

echo "Deployment finished"