# this section stores the terraform state for the s3 bucket in the terraform state bucket we created in step 1.
terraform {
  backend "s3" {
    bucket = "" # the terraform state bucket has to be hand entered unfortunately
    key    = "s3/sftp_config_bucket/terraform.tfstate"
    region = "us-east-1"
    encrypt = "true"
  }
}

# this is for an aws specific provider(not gcp or azure)
provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

# create an s3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket        = "${var.bucket_name}"
  force_destroy = "true"

  versioning {
    enabled = "${var.versioning}"
  }

  tags { 
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}