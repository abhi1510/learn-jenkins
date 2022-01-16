crumb=$(curl -u "jenkins:1234" -s 'http://localhost:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)')
# curl -u "jenkins:1234" -H $crumb -X POST http://localhost:8080/job/my-first-job/build?delay=0sec
curl -u "jenkins:1234" -H $crumb -X POST http://localhost:8080/job/backup-db-aws/buildWithParameters?MYSQL_HOST=db&MYSQL_DB=testdb&AWS_S3_BUCKET=my-bucket