#!/bin/bash

DATE=$(date +%H-%M-%S)
DB_HOST=$1
DB_PASS=$2
DB_NAME=$3
AWS_ACCESS=$4
AWS_SECRET=$5
BUCKET_NAME=$6

echo 'Backing up db'
mysqldump -u root -h $DB_HOST -p$DB_PASS $DB_NAME > /tmp/db-$DATE.sql 

export AWS_ACCESS_KEY_ID=$AWS_ACCESS
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET

echo 'Uploading to S3'
aws s3 cp /tmp/db-$DATE.sql s3://$BUCKET_NAME/db-$DATE.sql