#!/bin/sh -xe

#
# main entry point to run s3cmd
#
S3CMD_PATH=/opt/s3cmd/s3cmd

#
# Check for required parameters
#
if [ -z "${aws_key}" ]; then
    echo "The environment variable aws_key is not set. Attempting to create empty creds file to use role."
    aws_key=""
fi

if [ -z "${aws_secret}" ]; then
    echo "The environment variable aws_secret is not set."
    aws_secret=""
    security_token=""
fi

if [ -z "${DEST_S3}" ]; then
    echo "The environment variable DEST_S3 is not set."
    aws_secret=""
    security_token=""
fi


#
# Replace key and secret in the /.s3cfg file with the one the user provided
#
echo "" >> ${PROJECT_PATH}/s3cfg
echo "access_key = ${aws_key}" >> ${PROJECT_PATH}/s3cfg
echo "secret_key = ${aws_secret}" >> ${PROJECT_PATH}/s3cfg

if [ -z "${security_token}" ]; then
    echo "security_token = ${aws_security_token}" >> ${PROJECT_PATH}/s3cfg
fi

#
# Add region base host if it exist in the env vars
#
if [ "${s3_host_base}" != "" ]; then
  sed -i "s/host_base = s3.amazonaws.com/# host_base = s3.amazonaws.com/g" ${PROJECT_PATH}/s3cfg
  echo "host_base = ${s3_host_base}" >> /.s3cfg
fi

#
# Create and archive of current rancher-data and use current date and time as it's PROJECT_NAME
#

ARCHIVE_NAME=$(date '+%Y-%m-%d-%H:%M:%S')
tar -zcvf ~/$ARCHIVE_NAME.tar.gz ~/rancher-data

#
# Upload to S3
#
${S3CMD_PATH} --config=${PROJECT_PATH}/s3cfg sync ~/$ARCHIVE_NAME.tar.gz ${DEST_S3}

#
# Remove uploaded archive from container
#

rm -f ~/$ARCHIVE_NAME.tar.gz

#
# Finished operations
#
echo "Done!"
