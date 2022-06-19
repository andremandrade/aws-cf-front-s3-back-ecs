
aws cloudformation create-stack --stack-name aws-cloudformation01-test --template-body file://`pwd`/cloudformation-template.yml

aws cloudformation describe-stack-resource --stack-name aws-cloudformation01-test --logical-resource-id WebSiteBucket

aws cloudformation update-stack --stack-name aws-cloudformation01-test --template-body file://`pwd`/cloudformation-template.yml

aws cloudformation describe-stack-resource --stack-name aws-cloudformation01-test --logical-resource-id WebSiteBucket --query StackResourceDetail.PhysicalResourceId --output text



aws s3 sync ./web-frontend/dist/web-frontend/ s3://$S3_BUCKET_NAME