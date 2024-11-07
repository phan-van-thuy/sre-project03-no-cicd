#!/bin/bash

DEPLOY_INCREMENTS=1  # Tăng mỗi lần 1 pod

function manual_verification {
  read -p "Continue deployment? (y/n) " answer

  if [[ $answer =~ ^[Yy]$ ]] ; then
    echo "Continuing deployment"
  else
    exit
  fi
}

function canary_deploy {
  NUM_OF_V1_PODS=$(kubectl get pods -n udacity | grep -c canary-v1)
  echo "V1 PODS: $NUM_OF_V1_PODS"
  NUM_OF_V2_PODS=$(kubectl get pods -n udacity | grep -c canary-v2)
  echo "V2 PODS: $NUM_OF_V2_PODS"

  # Tăng v2 và giảm v1
  kubectl scale deployment canary-v2 --replicas=$((NUM_OF_V2_PODS + DEPLOY_INCREMENTS)) -n udacity
  kubectl scale deployment canary-v1 --replicas=$((NUM_OF_V1_PODS - DEPLOY_INCREMENTS)) -n udacity

  # Kiểm tra trạng thái triển khai của canary-v2
  ATTEMPTS=0
  ROLLOUT_STATUS_CMD="kubectl rollout status deployment/canary-v2 -n udacity"
  until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
    echo "Waiting for rollout to complete..."
    ATTEMPTS=$((ATTEMPTS + 1))  # Sửa ATTEMPTS thay vì attempts
    sleep 1
  done

  if [ $ATTEMPTS -eq 60 ]; then
    echo "Canary deployment timed out. Please check the status manually."
    exit 1
  fi

  echo "Canary deployment of $DEPLOY_INCREMENTS replicas successful!"
}

# Khởi tạo deployment của canary-v2
kubectl apply -f canary-v2.yml

sleep 1

# Bắt đầu triển khai canary
while [ $(kubectl get pods -n udacity | grep -c canary-v1) -gt 0 ]
do
  canary_deploy
  manual_verification
done

echo "Canary deployment of v2 successful"
