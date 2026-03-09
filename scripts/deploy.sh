#!/bin/bash
set -e

SERVER_IP=$1

echo "Deploying application to $SERVER_IP"

# SSH/SCP will use the Jenkins sshagent credential automatically
scp -o StrictHostKeyChecking=no app/index.html ubuntu@$SERVER_IP:/tmp/

ssh -o StrictHostKeyChecking=no ubuntu@$SERVER_IP << EOF
sudo mv /tmp/index.html /var/www/html/index.html
sudo systemctl restart nginx
EOF

echo "Deployment finished"