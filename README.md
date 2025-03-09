# Python part
In the python module we generate the zip file for AWS Lambda that includes the needed pip packages and the latest python code. Also later we will focus in use container images instead for zip files.

For Zip file Lambda version:
first create `venv`:
```
python3 -m venv venv
source venv/bin/activate
```

Once activated the venv, install dependencies from requirements.txt inside your venv:
pip install -r requirements.txt


Later, go to the folder "package_to_zip" and package all the dependencies and zip it:
```
cd package_to_zip
pip install --target package_to_zip -r requirements.txt
cp index.py package_to_zip/
cd package_to_zip
zip -r ../../terraform/lambda.zip .
cd ..
```

## Creating Python image with ECR
Following this AWS official guide: https://docs.aws.amazon.com/lambda/latest/dg/python-image.html
First go to the "python" folder, and because I use M1 Mac (ARM64) I build the image using:
```
docker buildx build --platform linux/amd64 -t python/omdb:V1.0 .
```
Or in case you use Linux:
```
docker build -t python/omdb:v1.0 .
```

Later Tag the image and push it to AWS:
```
docker tag python/omdb:V1.0 <AWS-ECR-URL>:V1.0

docker push <AWS-ECR-URL>:V1.0
```


# Terraform part
## Setting up S3 Backend to store and centralize the tfstate file
First you have to create your S3 bucket Backend:
```
aws s3 mb s3://my-terraform-state-${RANDOM} --region eu-central-1 
```
and then enabling Versioning to this S3:

```
aws s3api put-bucket-versioning --bucket <YOUR-BUCKET-NAME> --versioning-configuration Status=Enabled
```

Verify if s3 versioning is now enabled:
```
aws s3api get-bucket-versioning --bucket <YOUR-BUCKET-NAME>
```

Now that is created the S3 Bucket, now change your backend.tf with its correct bucket name!


## Running Terraform from Local Machine
Start with Terraform Init selecting the S3 Backend bucket:
```
terraform init -backend-config="bucket=<YOUR-BUCKET-NAME>" \
               -backend-config="region=eu-central-1"
```

Once is connected with the S3 Backend, run the other terraform commands:
```
terraform plan
terraform apply
```


## Running Terraform from Pipeline
As already configured in the CD.yaml, the terraform init Job is configured using CICD env variables:
```
terraform init -backend-config="bucket=${{ env.TF_S3_BUCKET_BACKEND_NAME }}" \
                     -backend-config="region=${{ env.AWS_REGION }}"
```


## Testing deployed Lambda
To test the API CALL, use this URL structure: https://`<AWS-URL>`?apikey=`<APIKEY>`&t=titanic