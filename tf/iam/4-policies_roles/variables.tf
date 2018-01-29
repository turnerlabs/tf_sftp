variable "region" {
  description = "Region"
  default     = "us-east-1"
}

variable "profile" {
  description = "Profile from credentials"
  default     = "default"
}

# full arn required here arn:aws:s3:::thebucket
variable "config_bucket_name" {}

# full arn required here arn:aws:s3:::thebucket/*
variable "config_bucket_name_extended" {}

# full arn required here arn:aws:s3:::thebucket
variable "bucket_name" {}

# full arn required here arn:aws:s3:::thebucket/*
variable "bucket_name_extended" {}