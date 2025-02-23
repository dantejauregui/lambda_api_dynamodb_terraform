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

## Testing deployed Lambda
To test the API CALL, use this URL structure: https://`<AWS-URL>`?apikey=`<APIKEY>`&t=titanic