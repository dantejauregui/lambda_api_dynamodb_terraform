# Python part
In the python module we generate the zip file for AWS Lambda that includes the needed pip packages and the latest python code. Also later we will focus in use container images instead for zip files.

For Zip file Lambda version:
first create `venv`:
```
cd python
python3 -m venv venv
source venv/bin/activate
```

Once activated the venv, install dependencies from requirements.txt inside your venv:
`pip install -r requirements.txt`


Later, locate yourself in the folder `/python` and package all the dependencies from there, and zip it (the zip file we move it inside the Terraform folder, in order to later can be taken to create the infrestructure):
```
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


# Terraform Setup part
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


=======



# Terraform Modules Part
## DynamoDB Module

In this project, I am using both hash_key (Partition Key) and range_key (Sort Key), where it will be assigned to the following attributes in my DynamoDB Table:

- hash_key = `name` attribute (column)
- range_key = `favorite_movie` attribute (column)
- and `age` as normal attribute

This means each `name` can store multiple favorite movies:

| Name  | Favorite Movie |
|-------|--------------|
| Alice | Titanic     |
| Alice | Inception   |
| Bob   | Avatar      |

BUT, If Only Using hash_key (Partition Key) means:  each `name` cannot store multiple favorite movies!

