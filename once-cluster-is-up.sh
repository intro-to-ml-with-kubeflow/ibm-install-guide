#!/usr/bin/env bash


## Assumes cluster has been created and is up and running... eventually merge these scripts..

if [ -z "$CLUSTER_NAME" ]; then
    echo "CLUSTER_NAME not set, we're gonna call this one 'kubeflow_tutorial'"
    export CLUSTER_NAME=kubeflow_tutorial
fi


export KUBECONFIG=$(ibmcloud cs cluster-config $CLUSTER_NAME | sed -n 's/.*KUBECONFIG=//p')

if [ -f ./set-aws-creds.sh ]; then
		echo "Found 'set-aws-creds.sh' , loading creds from there"
    source ./set-aws-creds.sh
fi

## Need better check on wheather that is working or not
"${AWS_ACCESS_KEY_ID:?Need to set AWS_ACCESS_KEY_ID non-empty}"
"${AWS_SECRET_ACCESS_KEY:?Need to set AWS_SECRET_ACCESS_KEY non-empty}"


if [! -d "kf-tutorial" ]; then
	echo "Cloning MNIST Example"
	mkdir kf-tutorial
	cd kf-tutorial
	git init
	git remote add origin -f https://github.com/kubeflow/examples
	echo mnist >> .git/info/sparse-checkout
	git pull origin master
	echo "Example source code cloned"
fi

# but for now, do that manually and then
cd kf-tutorial/mnist

APP_NAME=my-kubeflow
NAMESPACE=tfworkflow
# if directory exists, delete it.
if [ -d "$APP_NAME" ]; then
	echo "Deleting $APP_NAME"
	rm $APP_NAME -rf
fi

#tag::startProject[]
kubectl create namespace ${NAMESPACE}
ibmcloud cr namespace-add $NAMESPACE
ks init ${APP_NAME}
cd ${APP_NAME}

ks registry add kubeflow github.com/kubeflow/kubeflow/tree/v0.2.4/kubeflow
ks pkg install kubeflow/core@v0.2.4
ks pkg install kubeflow/argo

ks generate core kubeflow-core --name=kubeflow-core --namespace=${NAMESPACE}
ks generate argo kubeflow-argo --name=kubeflow-argo --namespace=${NAMESPACE}

ks apply default -c kubeflow-core
ks apply default -c kubeflow-argo

# Switch context for the rest of the example
kubectl config set-context $(kubectl config current-context) --namespace=${NAMESPACE}
#end::startProject[]

cd -

# Create a user for our workflow
kubectl apply -f tf-user.yaml

### If this hasn't been done yet...
#tag::configureDockerRegistry[]
DOCKER_BASE_URL=registry.ng.bluemix.net/$NAMESPACE # Put your docker registry here
#end::configureDockerRegistry[]
#docker build . --no-cache  -f Dockerfile.model -t ${DOCKER_BASE_URL}/mytfmodel:1.7
#
#docker push ${DOCKER_BASE_URL}/mytfmodel:1.7

## Create S3 Creds
#tag::configureStorage[]
export S3_ENDPOINT=s3-api.us-geo.objectstorage.softlayer.net  #replace with your s3 endpoint in a host:port format, e.g. minio:9000
export AWS_ENDPOINT_URL=https://${S3_ENDPOINT} #use http instead of https for default minio installs
export AWS_REGION=us-geo
export BUCKET_NAME=mnist-bucket-tutorial
export S3_USE_HTTPS=1 #set to 0 for default minio installs
export S3_VERIFY_SSL=1 #set to 0 for defaul minio installs

kubectl create secret generic aws-creds --from-literal=awsAccessKeyID=${AWS_ACCESS_KEY_ID} \
 --from-literal=awsSecretAccessKey=${AWS_SECRET_ACCESS_KEY}


#export S3_DATA_URL=s3://${BUCKET_NAME}/data/mnist/
export S3_DATA_URL=s3://${BUCKET_NAME}/
export S3_TRAIN_BASE_URL=s3://${BUCKET_NAME}
#export S3_TRAIN_BASE_URL=s3://${BUCKET_NAME}
export JOB_NAME=myjob-$(uuidgen  | cut -c -5 | tr '[:upper:]' '[:lower:]')
export TF_MODEL_IMAGE=${DOCKER_BASE_URL}/mytfmodel:1.7
export TF_WORKER=3
export MODEL_TRAIN_STEPS=2
export MODEL_BATCH_SIZE=1
#end::configureStorage[]

## Upload mnist/data to S3_DATA_URL
aws --endpoint-url $AWS_ENDPOINT_URL s3 cp data/0.png $S3_TRAIN_BASE_URL
aws --endpoint-url $AWS_ENDPOINT_URL s3 cp data/1.png $S3_TRAIN_BASE_URL
aws --endpoint-url $AWS_ENDPOINT_URL s3 cp data/2.png $S3_TRAIN_BASE_URL
aws --endpoint-url $AWS_ENDPOINT_URL s3 cp data/3.png $S3_TRAIN_BASE_URL
aws --endpoint-url $AWS_ENDPOINT_URL s3 cp data/4.png $S3_TRAIN_BASE_URL
aws --endpoint-url $AWS_ENDPOINT_URL s3 cp data/5.png $S3_TRAIN_BASE_URL
aws --endpoint-url $AWS_ENDPOINT_URL s3 cp data/6.png $S3_TRAIN_BASE_URL
aws --endpoint-url $AWS_ENDPOINT_URL s3 cp data/7.png $S3_TRAIN_BASE_URL
aws --endpoint-url $AWS_ENDPOINT_URL s3 cp data/8.png $S3_TRAIN_BASE_URL
aws --endpoint-url $AWS_ENDPOINT_URL s3 cp data/9.png $S3_TRAIN_BASE_URL


## Submit the Job

argo submit model-train.yaml --serviceaccount tf-user \
    -p aws-endpoint-url=${AWS_ENDPOINT_URL} \
    -p s3-endpoint=${S3_ENDPOINT} \
    -p aws-region=${AWS_REGION} \
    -p tf-model-image=${TF_MODEL_IMAGE} \
    -p s3-data-url=${S3_DATA_URL} \
    -p s3-train-base-url=${S3_TRAIN_BASE_URL} \
    -p job-name=${JOB_NAME} \
    -p tf-worker=${TF_WORKER} \
    -p model-train-steps=${MODEL_TRAIN_STEPS} \
    -p model-batch-size=${MODEL_BATCH_SIZE} \
    -p s3-use-https=${S3_USE_HTTPS} \
    -p s3-verify-ssl=${S3_VERIFY_SSL} \
    -p namespace=${NAMESPACE} \
    -n ${NAMESPACE}

PODNAME=$(kubectl get pod -l app=argo-ui -n${NAMESPACE} -o jsonpath='{.items[0].metadata.name}')
kubectl port-forward ${PODNAME} 8001:8001

echo "visit http://127.0.0.1:8001 to see the status of your workflows"
