
aws cloudformation create-stack --stack-name aws-cloudformation01-test --template-body file://`pwd`/cloudformation-template.yml

aws cloudformation describe-stack-resource --stack-name aws-cloudformation01-test --logical-resource-id WebSiteBucket

aws cloudformation update-stack --stack-name aws-cloudformation01-test --template-body file://`pwd`/cloudformation-template.yml

aws cloudformation describe-stack-resource --stack-name aws-cloudformation01-test --logical-resource-id WebSiteBucket --query StackResourceDetail.PhysicalResourceId --output text



aws s3 sync ./web-frontend/dist/web-frontend/ s3://$S3_BUCKET_NAME

aws ecr get-login-password --region us-west-2 --profile andre | docker login --username AWS --password-stdin 380095960694.dkr.ecr.us-west-2.amazonaws.com

docker tag cf01-api-service:latest 380095960694.dkr.ecr.us-west-2.amazonaws.com/cf01-api-service:latest

docker push 380095960694.dkr.ecr.us-west-2.amazonaws.com/cf01-api-service:latest

aws ecs register-task-definition --family CF01ECSServiceAPI --execution-role-arn arn:aws:iam::380095960694:role/ecsTaskExecutionRole --network-mode awsvpc --container-definitions "{\"name\": \"CF01API\",\"image\":\"380095960694.dkr.ecr.us-west-2.amazonaws.com/cf01-api:21c109e\",\"cpu\": 512,\"memory\":1024,\"portMappings\":[{\"containerPort\": 8080}],\"essential\": true}" --cpu 1024 --memory 2048

aws ecs update-service --cluster CF01ECSCluster --service CF01ECSServiceAPI --task-definition CF01ECSServiceAPI:2

aws ecs list-task-definitions --family-prefix CF01ECSServiceAPI --sort DESC --query taskDefinitionArns[0] --output text
