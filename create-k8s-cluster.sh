#!/usr/bin/env bash


# assumes you are logged in
# ibmcloud login

# assumes you have already targeted the resource group you want
# ibmcloud target -g <resource_group_name>

## use awk or something to get the zone
ibmcloud ks zones
ZONE=wdc06
ibmcloud ks machine-types $ZONE
# Cheap-o machines
MACHINE_TYPE=u2c.2x4
ibmcloud ks vlans $ZONE

CLUSTER_NAME=kubeflow_tutorial
K8S_VERSION=1.10.11
ibmcloud ks cluster-create --zone $ZONE \
    --machine-type $MACHINE_TYPE \
    --workers 3 --name $CLUSTER_NAME --kube-version $K8S_VERSION
