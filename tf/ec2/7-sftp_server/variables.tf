variable "region" {
  description = "Region"
  default     = "us-east-1"
}

variable "profile" {
  description = "Profile from credentials"
  default     = "default"
}

variable "tag_application" {}
variable "tag_contact_email" {}
variable "tag_customer" {}
variable "tag_team" {}
variable "tag_environment" {}

# The id of the AMI you created in packer
variable "image_id" {}

# The instance type to launch.  I default to the smallest.
variable "instance_type" {
  description = "EC2 Instance Type"
  default     = "t2.micro"
}

# The ssh pem key to use.  Creating one of these is out of the scope of terraform.
variable "key_name" {}

# The IAM EC2 instance profile to use.  This provides the instance with role based access to the s3 bucket.
variable "iam_instance_profile" {
  description = "IAM Instance profile"
  default     = "sftp-instance-profile"
}
