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

## Get output from this and set PRIV_VLAN and PUB_VLAN
## NOTE: ON first run, these won't exist, and in that case exclude last line of ibmcloud ks cluster-create ...
ibmcloud ks vlans $ZONE
PRIV_VLAN_ID=2523189
PUB_VLAN_ID=2523187

K8S_VERSION=1.10.11
ibmcloud ks cluster-create --zone $ZONE \
    --machine-type $MACHINE_TYPE \
    --workers 3 --name $CLUSTER_NAME --kube-version $K8S_VERSION \
		--public-vlan $PUB_VLAN_ID --private-vlan $PRIV_VLAN_ID
