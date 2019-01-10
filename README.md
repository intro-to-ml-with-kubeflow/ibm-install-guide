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
./create-k8s-cluster.sh
```

Wait 10 minutes or so for that to spin up...

#### Step4: Install Kube and load the model


##### Set AWS ENV Variables 
```bash
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
```

OR create file called `set-aws-creds.sh` that looks like this
```bash
#!/usr/bin/env bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
```

^^ `once-cluster-is-up.sh` will look for that file and run it if it exists.



Now build the docker image.
```bash
export DOCKER_BASE_URL=registry.ng.bluemix.net/$NAMESPACE # Put your docker registry here
docker build . --no-cache  -f Dockerfile.model -t ${DOCKER_BASE_URL}/mytfmodel:1.7
docker push ${DOCKER_BASE_URL}/mytfmodel:1.7
```

Now run the script and cross your fingers:
```bash
source ./once-cluster-is-up.sh
```



 