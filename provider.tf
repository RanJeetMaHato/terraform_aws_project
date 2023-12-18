provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "my-bucket-for-testing-ranjeet"
    key    = "tfstste-file"
    region = "us-east-1"
  }
}
