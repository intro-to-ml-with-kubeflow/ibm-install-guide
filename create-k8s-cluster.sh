#!/usr/bin/env bash

if [ -z "$CLUSTER_NAME" ]; then
    echo "CLUSTER_NAME not set, we're gonna call this one 'kubeflow_tutorial'"
    export CLUSTER_NAME=kubeflow_tutorial
fi

if [ -z "$MACHINE_TYPE" ]; then
		echo "MACHINE_TYPE not set, we're gonna use the cheap-os aka 'u2c.2x4'.  Please run 'ibmcloud ks machine-types $ZONE' to see all available machines"
		MACHINE_TYPE=u2c.2x4
fi
# assumes you are logged in
# ibmcloud login

# assumes you have already targeted the resource group you want
# ibmcloud target -g <resource_group_name>

## Use the last one as the Zone
ZONE=$(ibmcloud ks zones | tail -1)

echo "Zone set: $ZONE"

## Get output from this and set PRIV_VLAN and PUB_VLAN
## NOTE: ON first run, these won't exist, and in that case exclude last line of ibmcloud ks cluster-create ...

ZONE=$(ibmcloud ks zones | tail -1)
K8S_VERSION=1.10.11

VLAN_LIST=$(ibmcloud ks vlans $ZONE | tail -1)
if [[ $VLAN_LIST == ID* ]]; then
	echo "Creating Cluster and VLANs"
	ibmcloud ks cluster-create --zone $ZONE \
    --machine-type $MACHINE_TYPE \
    --workers 3 --name $CLUSTER_NAME --kube-version $K8S_VERSION
else
	echo "VLANs exist, creating cluster"
	PRIV_VLAN_ID=$(ibmcloud ks vlans $ZONE | sed -n 's/private.*//p' | cut -d' ' -f1)
	PUB_VLAN_ID=$(ibmcloud ks vlans $ZONE | sed -n 's/public.*//p' | cut -d' ' -f1)
	ibmcloud ks cluster-create --zone $ZONE \
    --machine-type $MACHINE_TYPE \
    --workers 3 --name $CLUSTER_NAME --kube-version $K8S_VERSION \
		--public-vlan $PUB_VLAN_ID --private-vlan $PRIV_VLAN_ID
fi

echo "Check Cluster exists in Web GUI for now... give it 10 then run next script"
