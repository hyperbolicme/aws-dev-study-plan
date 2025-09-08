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
