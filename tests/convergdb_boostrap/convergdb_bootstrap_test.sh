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

# Local

echo "confirm variables file was created"
result=`cat integration-test-convergdb-bootstrap-variables-file-path | wc -w`
if [ $result == 0 ]
  then
    exit 1;
fi

echo "confirm backend file was created"
result=$(printf %s $(cat integration-test-convergdb-bootstrap-backend-file-path))
backend_file='{"terraform":{"backend":{"s3":{"bucket":"integration-test-convergdb-bootstrap-admin-bucket","key":"terraform/convergdb.tfstate","dynamodb_table":"integration-test-convergdb-bootstrap-lock-table","region":"us-west-2"}}}}'
if [ $result != $(echo $backend_file) ]
  then
    exit 1;
fi

# S3 bucket

echo "confirm that data bucket was created and enabled object lifecycle expiration"
result=`aws s3api get-bucket-lifecycle-configuration --bucket integration-test-convergdb-bootstrap-data-bucket | jq .Rules[0].NoncurrentVersionExpiration.NoncurrentDays`
if [ $result != 7 ]
  then
    exit 1;
fi

echo "confirm that admin bucket was created and enabled object lifecycle expiration"
result=`aws s3api get-bucket-lifecycle-configuration --bucket integration-test-convergdb-bootstrap-admin-bucket | jq .Rules[0].Expiration.Days`
if [ $result != 3 ]
  then
    exit 1;
fi

echo "confirm admin bucket created object lifecycle expiration prefix"
result=`aws s3api get-bucket-lifecycle-configuration --bucket integration-test-convergdb-bootstrap-admin-bucket | jq -r .Rules[0].Filter.Prefix`
if [ $result != "integtest-deployment-id/tmp/" ]
  then
    exit 1;
fi

# DynamoDB

echo "confirm that hash key name of dynamodb was created"
result=`aws dynamodb describe-table --table-name integration-test-convergdb-bootstrap-lock-table | jq .Table.KeySchema[0].AttributeName`
if [ $result != "\"LockID\"" ]
  then
    exit 1;
fi

echo "confirm that hash key of dynamodb was created"
result=`aws dynamodb describe-table --table-name integration-test-convergdb-bootstrap-lock-table | jq .Table.KeySchema[0].KeyType`
if [ $result != "\"HASH\"" ]
  then
    exit 1;
fi

echo "confirm that read capacity of dynamodb was created"
result=`aws dynamodb describe-table --table-name integration-test-convergdb-bootstrap-lock-table | jq .Table.ProvisionedThroughput.ReadCapacityUnits`
if [ $result != 5 ]
  then
    exit 1;
fi

echo "confirm that write capacity of dynamodb was created"
result=`aws dynamodb describe-table --table-name integration-test-convergdb-bootstrap-lock-table | jq .Table.ProvisionedThroughput.WriteCapacityUnits`
if [ $result != 5 ]
  then
    exit 1;
fi

# VPC

echo "confirm that vpc was created"
result=`aws ec2 describe-vpcs --filters Name=tag:Name,Values=convergdb-integtest-deployment-id | jq .Vpcs[0].Tags[0].Value`
if [ $result != "\"convergdb-integtest-deployment-id\"" ]
  then
    exit 1;
fi

echo "confirm that subnets were created"
result=`aws ec2 describe-subnets --filters Name=tag:Name,Values=convergdb-integtest-deployment-id | jq .Subnets[0].Tags[0].Value`
if [ $result != "\"convergdb-integtest-deployment-id\"" ]
  then
    exit 1;
fi

echo "confirm that internet gateway was created"
result=`aws ec2 describe-internet-gateways --filters Name=tag:Name,Values=convergdb-integtest-deployment-id | jq .InternetGateways[0].Tags[0].Value`
if [ $result != "\"convergdb-integtest-deployment-id\"" ]
  then
    exit 1;
fi

echo "confirm that the route table was created"
result=`aws ec2 describe-vpcs --filters Name=tag:Name,Values=convergdb-integtest-deployment-id | jq .Vpcs[0].VpcId`
if [ $result == null ]
  then
    exit 1;
fi
result_rt=`aws ec2 describe-route-tables --filters Name=vpc-id,Values=$result | jq .RouteTables[0].VpcId`
if [ $result_rt != $result ]
  then
    exit 1;
fi

# Fargate

echo "confirm ecs cluster was created"
result=`aws ecs describe-clusters --cluster convergdb-integtest-deployment-id | jq .clusters[0].clusterName`
if [ $result != "\"convergdb-integtest-deployment-id\"" ]
  then
    exit 1;
fi

echo "confirm cloudwatch log group was created"
result=`aws logs describe-log-groups --log-group-name convergdb-integtest-deployment-id | jq .logGroups[0].logGroupName`
if [ $result != "\"convergdb-integtest-deployment-id\"" ]
  then
    exit 1;
fi

echo "confirm iam role for fargate ecs containers was created"
result=`aws iam get-role --role-name convergdb-integtest-deployment-id-execution-task-role | jq -c .Role.AssumeRolePolicyDocument`
role_policy="{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ecs-tasks.amazonaws.com\"},\"Action\":\"sts:AssumeRole\"}]}"
if [ $result != $(echo $role_policy) ]
  then
    exit 1;
fi

echo "confirm the policy was attached to the created role"
result=`aws iam get-role-policy --role-name convergdb-integtest-deployment-id-execution-task-role --policy-name convergdb_execution_task_role | jq -c .PolicyDocument`
role_policy="{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"ecs:*\",\"ecr:GetAuthorizationToken\",\"ecr:BatchCheckLayerAvailability\",\"ecr:GetDownloadUrlForLayer\",\"ecr:BatchGetImage\",\"logs:CreateLogStream\",\"logs:PutLogEvents\"],\"Resource\":\"*\"}]}"
if [ $result != $(echo $role_policy) ]
  then
    exit 1;
fi

echo "destroying terraform deployment..."
terraform destroy -force
if [ $? != 0 ]
  then
    echo "terraform destroy failed"
    exit_code=2
fi

echo "terraform destroy succeeded, delete associated tf files"
if [ $exit_code != 2 ]
  then
    rm -f ./terraform.tfstate*
    rm -rf ./.terraform
fi

exit $exit_code