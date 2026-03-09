#!/bin/bash

SERVER_IP=$1

echo "Running health check on $SERVER_IP"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$SERVER_IP)

if [ "$STATUS" == "200" ]; then
    echo "Health Check Passed"
    exit 0
else
    echo "Health Check Failed"
    exit 1
fi