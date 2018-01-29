# tf_sftp

- This repo provides you with a packer and terraform script to create an sftp server that writes to an s3 bucket.

## Packer(https://www.packer.io/)

- The script in the packer directory creates the AWS ami.

- Please look a the README in the packer directory for more information on this part of the process.

## Terraform(https://www.terraform.io/)

- The script in the tf directory creates the whole stack in AWS using the above AMI

- Please look a the README in the tf directory for more information on this part of the process.

## Assumptions

- You already have run a tool to generate the access and secret keys for the environment you want to run this in.

- You already have the latest packer and terraform applications installed and within your path.

- The default profile in your ~/.aws/credentials file is set to the account you want this run in.  There's a bug in the s3 state provider that doesn't handle the passing of the profile correctly.

## Steps(High Level)

1. Run IAM terraform script to create all the IAM policies needed.

2. Run the packer script to create the AMI.

3. Run the terraform script to create the sftp instance.


## Steps(Specific)

Open a shell in the directory this README is located in.

Step 1

```bash
cd tf/s3/1-terraform-state/

terraform init

terraform apply -var 'tag_application=sftp server' -var 'tag_contact_email=john.doe@youremail.org' -var 'tag_customer=acustomer' -var 'tag_team=ateam' -var 'tag_environment=test'  -var 'bucket_name=terraform-state-bucket' -var 'versioning=true'
```

Step 2

```bash
cd ../2-sftp_config_bucket/

Modify the main.tf file and add the terraform backend bucket created in the first step above to the variable commented out.

terraform init -var 'tag_application=sftp server' -var 'tag_contact_email=john.doe@youremail.org' -var 'tag_customer=acustomer' -var 'tag_team=ateam' -var 'tag_environment=test'  -var 'bucket_name=sftp-config-bucket'

terraform apply -var 'tag_application=sftp server' -var 'tag_contact_email=john.doe@youremail.org' -var 'tag_customer=acustomer' -var 'tag_team=ateam' -var 'tag_environment=test'  -var 'bucket_name=sftp-config-bucket'
```

Step 3

```bash
cd ../3-sftp_upload_bucket/

Modify the main.tf file and add the terraform backend bucket created in the first step above to the variable commented out.

terraform init -var 'tag_application=sftp server' -var 'tag_contact_email=john.doe@youremail.org' -var 'tag_customer=acustomer' -var 'tag_team=ateam' -var 'tag_environment=test'  -var 'bucket_name=sftp-upload-bucket'

terraform apply -var 'tag_application=sftp server' -var 'tag_contact_email=john.doe@youremail.org' -var 'tag_customer=acustomer' -var 'tag_team=ateam' -var 'tag_environment=test'  -var 'bucket_name=sftp-upload-bucket'
```

Step 4

```bash
cd ../../iam/4-policies_roles/

Modify the main.tf file and add the terraform backend bucket created in the first step above to the variable commented out.

terraform init -var 'config_bucket_name=arn:aws:s3:::sftp-config-bucket' -var 'config_bucket_name_extended=arn:aws:s3:::sftp-config-bucket/*'  -var 'bucket_name=arn:aws:s3:::sftp-upload-bucket' -var 'bucket_name_extended=arn:aws:s3:::sftp-upload-bucket/*'

terraform apply -var 'config_bucket_name=arn:aws:s3:::sftp-config-bucket' -var 'config_bucket_name_extended=arn:aws:s3:::sftp-config-bucket/*'  -var 'bucket_name=arn:aws:s3:::sftp-upload-bucket' -var 'bucket_name_extended=arn:aws:s3:::sftp-upload-bucket/*'
```

Step 5

```bash
cd ../../../packer/5-cron_files/

Modify the cps3.sh file to use the bucket in step 3.  The line to modify starts with "sudo aws s3 cp" 
You may also want to modify 

Copy theses 2 files to the config bucket

aws s3 cp cps3.sh s3://sftp-config-bucket

aws s3 cp sshd_config s3://sftp-config-bucket
```

Step 6

```bash
cd ../6-ami_creation/

Modify the script below to use a vpc and an associated subnet in the command below.

aws ec2 describe-vpcs # might help with picking finding one.

aws ec2 describe-subnets  # make sure the subnets vpcid is the one selected in the command above

packer build -var 'tag_application=sftp server' -var 'tag_contact_email=john.doe@youremail.org' -var 'tag_customer=acustomer' -var 'tag_team=ateam' -var 'tag_environment=test' -var 'iam_instance_profile=sftp-instance-profile' -var 'sftpuser_password=sftp_user_password' -var 's3_config_bucket=s3://sftp-config-bucket' -var 'vpcid_to_build_in=your-vpc' -var 'subnetid_to_build_in=your-vpcs-subnet' ubuntu.json

Make a note of the ami id which should be something like ami-1234567 at the end of the ami creation
```

Step 7

```bash
cd ../../tf/ec2/7-sftp_server/

Modify the main.tf file and add the terraform backend bucket created in the first step above to the variable commented out.

Change the image_id to be the ami id you noted in the previous step

Change the key_name to be a key name you already created to access ec2 instances via ssh.

terraform init -var 'tag_application=sftp server' -var 'tag_contact_email=john.doe@youremail.org' -var 'tag_customer=acustomer' -var 'tag_team=ateam' -var 'tag_environment=test' -var 'image_id=ami-id-from-last-step' -var 'key_name=aws_key_pem' -var 'iam_instance_profile=sftp-instance-profile' -var 'instance_type=t2.micro'

terraform apply -var 'tag_application=sftp server' -var 'tag_contact_email=john.doe@youremail.org' -var 'tag_customer=acustomer' -var 'tag_team=ateam' -var 'tag_environment=test' -var 'image_id=ami-id-from-last-step' -var 'key_name=aws_key_pem' -var 'iam_instance_profile=sftp-instance-profile' -var 'instance_type=t2.micro'
```

Step 8

```bash
Login to the AWS console of the account you created this stack in.

Go to this link: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:search=sftpserver;sort=desc:launchTime

Wait for the status on the sftpserver to go from initializing to 2/2 checks.

Go to this link: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:search=elb-sftpserver

Try connecting to the sftp server via the DNS name of this load balancer:  sftp sftpuser@elb-sftpserver-965267337.us-east-1.elb.amazonaws.com

Use the password you used in step 6 to create the sftpuser.

Try up loading a file.

Go to this link: https://s3.console.aws.amazon.com/s3/home?region=us-east-1#

Look for the upload buckdet you created in step 3 and after a few minutes, verify you see the file appear.
```

## Debugging

Since this is essentially an ssh server allowing sftp connections you can ssh in thru the same elb connection using the ubuntu user with the key you specified in step 7.  If you login via ubuntu, the cps3.sh command will be in the directory you land in.  There is also a log directory that contains any cron failures to help with debugging.

 ## Safeguarding

 Even though the design of this terraform is to put this sftp server in its own vpc island with limited access to 2 s3 buckets, it is important to limit access through the elb security group here: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#SecurityGroups:search=sg_elb_sftpserver;sort=tag:Name
 
  **You should try to limit the source ip address to those that need it and never allow access from anywhere**

## Better alternatives

I built this to solve a problem we have now with third party vendors that don't have AWS accounts or use old systems that can only ftp.

If the third party vendor does have an AWS account, a much better solution is providing a cross account role.

You could also convert this into a container as long as you have enough storage.

You can also use a pre-signed url(https://docs.aws.amazon.com/AmazonS3/latest/dev/PresignedUrlUploadObject.html)