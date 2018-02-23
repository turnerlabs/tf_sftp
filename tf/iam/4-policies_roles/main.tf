# this section stores the terraform state for the s3 bucket in the terraform state bucket we created in step 1.
terraform {
  backend "s3" {
    bucket = "" # the terraform state bucket has to be hand entered unfortunately
    key    = "iam/policies_roles/terraform.tfstate"
    region = "us-east-1"
    encrypt = "true"
  }
}

# this is for an aws specific provider(not gcp or azure)
provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

# create the iam role to eventually be used by the sftp instance for file uploading
resource "aws_iam_role" "sftp-role" {
  name = "sftp-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# create the iam role to eventually be used by the sftp instance for file uploading
resource "aws_iam_role_policy" "sftp-policy" {
  name = "sftp-policy"
  role = "${aws_iam_role.sftp-role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": ["${var.bucket_name}", "${var.config_bucket_name}"]
    },
    {
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Effect": "Allow",
      "Resource": ["${var.bucket_name_extended}", "${var.config_bucket_name_extended}"]
    }    
  ]
}
EOF
}

# instance profile used to create the AMI
resource "aws_iam_instance_profile" "sftp-instance-profile" {
  name = "sftp-instance-profile"
  role = "${aws_iam_role.sftp-role.name}"
}
