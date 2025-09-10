# Software feature update - Reports

- added a feature to generate and save a report including weather, forcast and news top 5 into a store (S3 bucket). also to view reports available so far

- use aws sdk to put into bucket. npm install aws-sdk. use sdk v3 lower versions have issues. sdk apis like 
PutObjectCommand, ListObjectsV2Command, GetObjectCommand,
etc. bucket structure: weather-app-reports/reports/default_user/x.json. name is city-yyyy-mm-dd-time.json. can reverse engineer the time and date of the saved report

- 1 POST api to save a report. 1 GET api to get list of reports. 1 GET api to get a particular report

- there was a aws cli region setup issue. used aws configure set region to set it to the bucket's region

- when there are frontend issues, use curl to check backend

# backend refactoring

- split server.js into 25 different files. middleware - routes - controller - services. flow: middleware -> routes -> middleware -> controllers -> services

1. *Global middleware* runs first (CORS, body parsing, security headers)
2. *Routes* match the URL pattern and determine which controller to call
3. *Route-specific middleware* runs (like input validation for that specific endpoint)
4. *Controllers* handle the request and call services
5. *Services* do the actual business logic

- added 135 unit tests. 2 news service tests fail due to error handling issue. this is minor. will see later.

# CloudFront 
- create a bucket put frontend in it. can host from static webhosting in s3 option. but for CDN, create a cloudfront distribution. point origin to the s3 bucket. issue is CDN uses https so apis must also be called over https but backend is not hosted on https. it is an infra logistic process concern. so leaving it as is.
when the frontend is moved to s3 or CDN it is important to add their domains into cors so that traffic is accpeted by app.

# advanced aws cli
see notes

# server info endpoints and healthcheck updated to IMDS v2
v2 needs a token to get info from metadata service. explains why it wasn't working before, v1 method was used before.

```bash
ubuntu@ip-172-31-13-101:~/how-is-your-day$ curl http://localhost:5001/api/server-info
{"server":{"hostname":"ip-172-31-13-101","platform":"linux","uptime":912557.7,"port":"5001","node_version":"v18.20.8","timestamp":"2025-09-10T06:47:53.881Z"},"aws":{"instance_id":"i-09e25918b78c2f3e1","instance_type":"t3.micro","availability_zone":"ap-south-1b","is_ec2":true},"network":{"interfaces":{"lo":[{"address":"127.0.0.1","netmask":"255.0.0.0","family":"IPv4","mac":"00:00:00:00:00:00","internal":true,"cidr":"127.0.0.1/8"},{"address":"::1","netmask":"ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff","family":"IPv6","mac":"00:00:00:00:00:00","internal":true,"cidr":"::1/128","scopeid":0}],"ens5":[{"address":"172.31.13.101","netmask":"255.255.240.0","family":"IPv4","mac":"0a:26:f6:23:ee:2f","internal":false,"cidr":"172.31.13.101/20"},{"address":"fe80::826:f6ff:fe23:ee2f","netmask":"ffff:ffff:ffff:ffff::","family":"IPv6","mac":"0a:26:f6:23:ee:2f","internal":false,"cidr":"fe80::826:f6ff:fe23:ee2f/64","scopeid":2}]}},"deployment":{"environment":"development","base_url":"http://localhost:5001"}}ubuntu@ip-172-31-13-101:~/how-is-your-day$ 
ubuntu@ip-172-31-13-101:~/how-is-your-day$ curl http://localhost:5001/api/aws-metadata
{"aws_metadata":{"public_ip":"3.110.196.24","private_ip":"172.31.13.101","instance_id":"i-09e25918b78c2f3e1","instance_type":"t3.micro","availability_zone":"ap-south-1b","port":"5001","frontend_url":"http://3.110.196.24:5001","api_base":"http://3.110.196.24:5001/api"},"is_ec2":true,"metadata_version":"IMDSv2","checked_at":"2025-09-10T06:48:15.388Z"}ubuntu@ip-172-31-13-101:~/how-is-your-day$ curl http://localhost:5001/api/deployment-status
{"deployment":{"status":"active","platform":"AWS EC2","ip_address":"3.110.196.24","port":"5001","frontend_url":"http://3.110.196.24:5001","api_base":"http://3.110.196.24:5001/api","uptime":912610.72,"node_version":"v18.20.8","last_checked":"2025-09-10T06:48:46.904Z"},"aws":{"is_ec2":true,"instance_id":"i-09e25918b78c2f3e1","public_ip":"3.110.196.24","instance_type":"t3.micro","availability_zone":"ap-south-1b","metadata_version":"IMDSv2"},"server":{"hostname":"ip-172-31-13-101","local_ip":"172.31.13.101"}}ubuntu@ip-172-31-13-101:~/how-is-your-day$ 

```