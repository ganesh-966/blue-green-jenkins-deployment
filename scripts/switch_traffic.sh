#!/bin/bash

TARGET_GROUP=$1
LISTENER_ARN=$2

echo "Switching traffic to new environment..."

aws elbv2 modify-listener \
--listener-arn $LISTENER_ARN \
--default-actions Type=forward,TargetGroupArn=$TARGET_GROUP

echo "Traffic switched successfully"