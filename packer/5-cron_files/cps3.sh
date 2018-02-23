#!/bin/bash
shopt -s globstar nullglob dotglob &&\
for file in `sudo ls -1 /home/sftpusers/home/sftpuser`;\
  do who_has_it=$(sudo lsof "/home/sftpusers/home/sftpuser/$file");\
  if [[ -z $who_has_it ]] ; then
    sudo aws s3 cp "/home/sftpusers/home/sftpuser/$file" s3://your-upload-bucket/$file
    sudo rm -rf "/home/sftpusers/home/sftpuser/$file"
  else
    echo "file in use"
fi;done > /dev/null