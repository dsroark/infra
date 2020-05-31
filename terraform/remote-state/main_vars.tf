variable "aws_region" {
  default = "us-east-2"
}
variable "aws_profile" {
  default = "default"
}


variable "s3_bucket_name" {
  # note this will fail if ran as is
  default = "tfstate"
}

variable "dynamo_table_name" {
  # note this will fail if ran as is
  default = "app-state"
}


