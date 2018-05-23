exit_code=0

echo "initializing terraform deployment and getting modules..."
terraform init

echo "applying terraform deployment..."
terraform apply --auto-approve

echo "confirm that database was created"
aws glue get-database --name integration_test_databaseintegrationtest
if [ $? != 0 ]
  then
    echo "database name test failed"
    exit_code=1;
fi

echo "confirm that the convergdb_deployment_id attribute was set"
deployment_id=`aws glue get-database --name integration_test_databaseintegrationtest | jq -r ".Database.Parameters.convergdb_deployment_id"`
if [ $deployment_id != "integrationtest" ]
  then
    echo "database convergdb_deployment_id attribute test failed"
    exit_code=1;
fi

echo "destroying terraform deployment..."
terraform destroy --force
if [ $? != 0 ]
  then
    echo "terraform destroy failed"
    exit_code=2;
fi

# if terraform destroy succeeded, delete tf files
if [ $exit_code != 2 ]
  then
    rm -f ./terraform.tfstate*
    rm -rf ./.terraform;
fi

exit $exit_code

