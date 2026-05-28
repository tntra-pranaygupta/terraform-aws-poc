terraform {
  backend "s3" {
    # Replace this with your actual bucket name from backend-setup output
    bucket = "tf-poc-state-g95iruzw"
 
    # Path within the bucket — each environment gets its own key
    key    = "dev/terraform.tfstate"
 
    region  = "ap-south-1"
    encrypt = true
 
    # DynamoDB table for state locking
    dynamodb_table = "terraform-state-lock"
  }
}