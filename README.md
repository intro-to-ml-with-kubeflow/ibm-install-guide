# ibm-install-guide

~~An install guide for MS Office '03~~

A guide for installing Kubeflow on Bluemix, training a model, and serving it to friends and family.  


### Kubeflow Install

#### Step1: Sign up for Bluemix

Go to bluemix.net sign up. Put a CC in bc o/w you can only set up single node clusters. 

You'll probably need to download the CLI tools. See [this](https://console.bluemix.net/docs/containers/cs_cli_install.html#cs_cli_install)

#### Step2: Make a bucket

- 2a. Log in to Bluemix GUI
- 2b. Click Categlog (at top)
- 2c. Seach for `Cloud Object Storage`
- 2d. Click through and click "Create"
- 2e. Click `Create Bucket`, name it `kubeflow-tutorial`
- 2f. When in the bucket, click `Service Credentials` on left-hand side.
- 2g. Click `New Credential`
- 2h. On the screen that pops up, under `Add Inline Configuration Parameters (Optional)` add the line `{"HMAC":true}`
- 2i. Click `Add`
- 2j. Click `View Credentials` in the revealed JSON find the key, `cos_hmac_keys`. There you will find your `access_key_id` and `access_secret_key`

#### Step3: Create a Cluster

Login via CLI:

```bash
ibmcloud login
```

Run the script to create a small cluster.
```bash
export CLUSTER_NAME=kubeflow_tutorial
./create-k8s-cluster.sh
```

Wait 10 minutes or so for that to spin up...

#### Step4: Install Kube and load the model


Run this:

```bash
ibmcloud cs cluster-config $CLUSTER_NAME
```

It will give you a line to export- do that. 

The following _should_ just check out the MNIST example, but it pulls everything /shrug

```bash
mkdir kf-tutorial
cd kf-tutorial
git init
git remote add origin -f https://github.com/kubeflow/examples
echo mnist >> .git/info/sparse-checkout
git pull origin master
```

Set AWS ENV Variables
```bash
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
```

Now build the docker image.
```bash
export DOCKER_BASE_URL=registry.ng.bluemix.net/$NAMESPACE # Put your docker registry here
docker build . --no-cache  -f Dockerfile.model -t ${DOCKER_BASE_URL}/mytfmodel:1.7
docker push ${DOCKER_BASE_URL}/mytfmodel:1.7
```

Now run the script and cross your fingers:
```bash
./once-cluster-is-up.sh
```



 