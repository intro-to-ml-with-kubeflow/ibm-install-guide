#!/usr/bin/env bash

APP_NAME=my-kubeflow
NAMESPACE=tfworkflow
DOCKER_BASE_URL=registry.ng.bluemix.net/$NAMESPACE
export BUCKET_NAME=mnist-bucket-tutorial

kubectl get workflows

WORKFLOW=<the workflowname>
argo submit model-deploy.yaml -n ${NAMESPACE} -p workflow=${WORKFLOW} --serviceaccount=tf-user