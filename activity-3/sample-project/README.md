$(aws cloudformation list-exports --query "Exports[?Name=='SamBucket'].Value" --output text)



aws cloudformation package --template-file sample.yaml --output-template-file sample-transformed.yaml --s3-bucket $(aws cloudformation list-exports --query "Exports[?Name=='SamBucket'].Value" --output text)
aws cloudformation deploy --template-file sample-transformed.yaml --stack-name sample-project  --capabilities CAPABILITY_IAM