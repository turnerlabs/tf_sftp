# Description

This is a packer builder and custom proviosioner to create an AMI for sftp usage

## Builder

The builder phase uses a t2 micro in the east region as the instance type to run the provisioner on.  The instance size can be changed to something larger if you need to create the AMI faster.  This is just for building the AMI and has no bearing on the long running instance.  That is determined in the terraform script.

## Provisioner

The provisioner phase installs all the tools needed to create a basic sftp server with one sftp user.  If you take a look at the provision.sh script you can see all that's happening.

## Process

Once the provisioner has completed, an image will be created using the ami_name in the ubuntu.json file. 