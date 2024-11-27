
variable "region" {
  description = "Region to create the s3 bucket and dynamodb"
  type        = string
}

variable "environment" {
  description = "Environment DEV/QA/STG/PROD"
  type        = string
}

variable "team" {
  description = "Team name who will manage this resources"
  type        = string
}



variable "bucket_name" {
  description = "Name for the S3 bucket"
  type        = string
}

variable "path_to_json_file" {
  type        = string
  description = "Name of the json file with policy"
}

variable "dynamodb_table_name" {
  description = "Name for the DynamoDB table for state locking"
  type        = string
}