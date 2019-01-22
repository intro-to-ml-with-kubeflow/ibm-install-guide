#!/usr/bin/env bash

NAMESPACE=tfworkflow

echo "Deleteing kf-tutorial"
rm -rf kf-tutorial
echo "Deleting all pods"
kubectl delete pods --all -n $NAMESPACE
echo "Deleting secrets"
kubectl delete secret aws-creds -n $NAMESPACE
kubectl delete secret bluemix-tfworkflow-secret -n $NAMESPACE
kubectl delete secret bluemix-tfworkflow-secret-regional -n $NAMESPACE
kubectl delete secret bluemix-tfworkflow-secret-international -n $NAMESPACE
echo "Deleting Namespace"
# todo do it
