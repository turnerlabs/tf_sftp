# Description

These 2 files need to be modified and uploaded to the s3 config bucket created in step 2.  This needs to be completed before running step 5.

The cps3.sh file gets copied(during the provisioner phase of the packer script) to the cron directory on the sftp server and it gets run every minute.  This script contains logic to check files with the phrase "_new" in the file name to see if they are in use(still being uploaded) and skips them if they are.  Once the file is no longer in use it will get copied over to the s3 bucket you will eventually create in step 6.  You will need to modify the "s3://your-sftp-files-bucket/uploaded-files" code in this script to be the bucket you will eventually create in step 6.

The sshd_config file contains settings to tighten up the security on the ssh server and to allow secure ftp use.  No modifications should need to be made to this file.

## Items to think about
<font color='red'>

  * If you need to add more ftp users you will need to create one of these scripts for every user since this is just for the sftpuser.

  * This code looks for files with the suffix of _new so you may want to remove this logic.

   * The cps3.sh script will get run by cron every minute(located in the provision.sh file in the packer directory).  You will need to add more entries to the provision.sh file for additional users and you may want to stagger the cron execution times.
   
</font>