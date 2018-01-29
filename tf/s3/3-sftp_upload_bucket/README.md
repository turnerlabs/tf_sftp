# Description

This is a terraform script to create the s3 upload bucket.  The state of this bucket will be stored in the bucket created in step 1.

You will need to update the terraform / backend / bucket in main.tf to use the terraform state bucket you created in step 1.