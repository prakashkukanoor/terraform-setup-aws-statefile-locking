# Setup s3 and dynamodb for statefile storage and locking

# Commands to manually migrate the local state file to aws

- Create S3 bucket
```
aws s3api create-bucket --bucket tf-setup-prod-networking --region us-east-1 --create-bucket-configuration LocationConstraint=us-east-1
```

- Enable versioning on the bucket
```
aws s3api put-bucket-versioning --bucket tf-setup-prod-networking --versioning-configuration Status=Enabled
```

- Enable versioning on the bucket
```
aws s3api put-bucket-encryption --bucket my-terraform-state-bucket --server-side-encryption-configuration '{
  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }
  ]
}'

```

- Block public access to the bucket
```
aws s3api put-bucket-policy --bucket my-terraform-state-bucket --policy '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Deny",
                "Principal": "*",
                "Action": [
                    "s3:DeleteBucket",
                    "s3:DeleteObject"
                ],
                "Resource": [
                    "arn:aws:s3:::tf-setup-prod-networking",
                    "arn:aws:s3:::tf-setup-prod-networking/*"
                ]
            }
        ]
    }'
```

- Create DynamoDB Table
```
aws dynamodb create-table \
  --table-name tf-setup-prod-networking \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

- Upload local state file to the S3 bucket
```
aws s3 cp terraform.tfstate s3://tf-setup-prod-networking/project-name-xyz/tf-setup-s3-dynamoDb/terraform.tfstate

```

- Configure Terraform to Use the S3 Backend
```
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"        # Replace with your bucket name
    key            = "path/to/terraform.tfstate"        # Path where the state file is stored in the bucket
    region         = "us-east-1"                        # Replace with your region
    dynamodb_table = "terraform-state-lock"             # DynamoDB table for state locking
    encrypt        = true                               # Enable encryption for state file
  }
}
```
