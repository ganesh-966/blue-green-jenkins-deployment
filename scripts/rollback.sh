#!/bin/bash

OLD_TARGET_GROUP=$1
LISTENER_ARN=$2

echo "Deployment failed. Rolling back..."

aws elbv2 modify-listener \
--listener-arn $LISTENER_ARN \
--default-actions Type=forward,TargetGroupArn=$OLD_TARGET_GROUP

echo "Rollback completed"