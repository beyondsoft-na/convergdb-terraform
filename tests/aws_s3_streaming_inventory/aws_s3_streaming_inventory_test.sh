exit_code=0

echo "initializing terraform deployment and getting modules..."
terraform init
if [ $? != 0 ]
  then
    echo "terraform init failed"
    exit_code=1
fi

echo "applying terraform deployment..."
terraform apply -auto-approve
if [ $? != 0 ]
  then
    echo "terraform apply failed"
    exit_code=1
fi

echo "comfirm that source bucket was created"
aws s3api head-bucket --bucket s3-streaming-inventory-integration-test-source-bucket
if [ $? != 0 ]
  then
    echo "create source bucket failed"
    exit_code=1
fi

echo "comfirm that destonation bucket was created"
aws s3api head-bucket --bucket s3-streaming-inventory-integration-test-destination-bucket
if [ $? != 0 ]
  then
    echo "create destonation bucket failed"
    exit_code=1
fi

echo "confirm that firehose delivery stream was created"
aws firehose describe-delivery-stream --delivery-stream-name s3-streaming-inventory-integration-test-firehose-stream-name
if [ $? != 0 ]
  then
    echo "create firehose delivery stream failed"
    exit_code=1
fi

echo "confirm that lambda was created"
aws lambda get-function --function-name s3-streaming-inventory-integration-test-lambda-name
if [ $? != 0 ]
  then
    echo "create lambda failed"
    exit_code=1
fi

# upload one local file to source bucket
echo "contents of one object in source bucket" > test.txt
aws s3 cp test.txt s3://s3-streaming-inventory-integration-test-source-bucket
if [ $? != 0 ]
  then
    echo "upload test.txt to source bucket failed"
    exit_code=1
fi
echo "delete local file test.txt after uploading"
rm -f test.txt

# the second to sleep neeeds to be greater than buffer_interval in firehose
sleep_time=240
echo "waiting lambda and firehose work to be completed in $sleep_time seconds...... "
sleep $sleep_time

echo "confirm that data of s3 event whenever a new file arrives was deliveried to destination bucket"
result=`aws s3api list-objects-v2 --bucket s3-streaming-inventory-integration-test-destination-bucket --prefix s3-streaming-inventory-integration-test-destination-prefix | wc -w`
if [ $result == 0 ]; then
  echo "firhose that deliveries data to destination bucket failed"
  exit_code=1;
else
  aws s3api list-objects-v2 --bucket s3-streaming-inventory-integration-test-destination-bucket --prefix s3-streaming-inventory-integration-test-destination-prefix
fi

echo "confirm that all objects in the source bucket were deleted"
aws s3 rm s3://s3-streaming-inventory-integration-test-source-bucket/ --recursive
if [ $? != 0 ]
  then
    echo "delete objects in source bucket failed"
    exit_code=1;
fi

echo "confirm that all objects in the destination bucket were deleted"
aws s3 rm s3://s3-streaming-inventory-integration-test-destination-bucket/ --recursive
if [ $? != 0 ]
  then
    echo "delete objects in destination bucket failed"
    exit_code=1
fi

echo "destroying terraform deployment..."
terraform destroy -force
if [ $? != 0 ]
  then
    echo "terraform destroy failed"
    exit_code=2
fi

# if terraform destroy succeeded, delete tf files
if [ $exit_code != 2 ]
  then
    rm -f ./terraform.tfstate*
    rm -rf ./.terraform
fi

exit $exit_code
