# Week2 S3 Reports


## My Reports Feature Flow:

1. Generate Report (New Button)
Frontend: User clicks "Generate Daily Report" button
Backend: Creates comprehensive report and stores in S3

`// New endpoint: POST /api/generate-report
const report = {
  city: "Mumbai",
  date: "2024-09-02",
  weather: {
    current: { temp: 28, humidity: 65 },
    forecast: [/* 5-day data */]
  },
  news: [/* top 5 articles */],
  generated_at: new Date().toISOString()
};

// Store in S3
await s3.putObject({
  Bucket: 'weather-app-reports',
  Key: `reports/user123/mumbai-2024-09-02.json`,
  Body: JSON.stringify(report)
});
`

2. View My Reports (New Page)
Frontend: New page showing list of all saved reports
Backend: Lists user's reports from S3

`// New endpoint: GET /api/my-reports
await s3.listObjectsV2({
  Bucket: 'weather-app-reports',
  Prefix: 'reports/user123/'
});

// Returns: ['mumbai-2024-09-02.json', 'delhi-2024-09-01.json']

3. Download/View Report
Frontend: User clicks on any report to view/download
Backend: Retrieves specific report from S3

`// New endpoint: GET /api/report/:filename
await s3.getObject({
  Bucket: 'weather-app-reports', 
  Key: `reports/user123/mumbai-2024-09-02.json`
});`


## UI Flow:

Weather display
News display
➕ "Generate Report" button → Creates S3 report
➕ "My Reports" link → Lists all saved reports
➕ Report viewer → Shows individual reports


## 📁 S3 Structure:

`weather-app-reports/
├── reports/
│   ├── mumbai-2024-09-02-1693747200.json
│   ├── delhi-2024-09-01-1693660800.json`


## Implementation Plan:

Step 1: Create S3 bucket
Step 2: Add POST /api/generate-report endpoint
Step 3: Add GET /api/my-reports endpoint (lists all reports)
Step 4: Add GET /api/report/:filename endpoint
Step 5: Add frontend buttons and pages

## Notes

- created s3 bucket
weather-app-reports-hyperbolicme
Asia Pacific (Mumbai) ap-south-1
September 2, 2025, 11:18:11 (UTC+05:30)

- SSH into your EC2 and let's test the connection:

anju@192 how-is-your-day % aws s3 ls s3://weather-app-reports-hyperbolicme

Could not connect to the endpoint URL: "https://weather-app-reports-hyperbolicme.s3.ap-south1.amazonaws.com/?list-type=2&prefix=&delimiter=%2F&encoding-type=url"
anju@192 how-is-your-day % 


-- region configuration issue!
The error shows it's trying to connect to ap-south1 (missing dash) instead of ap-south-1.

-- also running from local machine. run from ec2 instance

note: EC2 Instance: "I live in ap-south-1" ✅
AWS CLI: "But I can work with ANY region the user wants" ✅
User: Must explicitly tell CLI which region to use ✅

so aws configure set must be used to set cli's region.

ubuntu@ip-172-31-13-101:~$ aws configure set region ap-south-1
ubuntu@ip-172-31-13-101:~$ aws configure get region
ap-south-1
ubuntu@ip-172-31-13-101:~$ 

-- check bucket connectivity

ubuntu@ip-172-31-13-101:~$ echo "hello s3" > test.txt
ubuntu@ip-172-31-13-101:~$ 
ubuntu@ip-172-31-13-101:~$ 
ubuntu@ip-172-31-13-101:~$ aws s3 cp test.txt S3://weather-app-reports/test.txt

usage: aws s3 cp <LocalPath> <S3Uri> or <S3Uri> <LocalPath> or <S3Uri> <S3Uri>
Error: Invalid argument type
ubuntu@ip-172-31-13-101:~$ aws s3 cp test.txt S3://weather-app-reports-hyperbolicme/test.txt

usage: aws s3 cp <LocalPath> <S3Uri> or <S3Uri> <LocalPath> or <S3Uri> <S3Uri>
Error: Invalid argument type
ubuntu@ip-172-31-13-101:~$ ls
how-is-your-day  temp.log  test.txt
ubuntu@ip-172-31-13-101:~$ aws s3 cp test.txt s3://weather-app-reports-hyperbolicme/test.txt
upload: ./test.txt to s3://weather-app-reports-hyperbolicme/test.txt
ubuntu@ip-172-31-13-101:~$ 
ubuntu@ip-172-31-13-101:~$ 
ubuntu@ip-172-31-13-101:~$ aws s3 ls s3://weather-app-reports-hyperbolicme
2025-09-02 06:24:28          9 test.txt
ubuntu@ip-172-31-13-101:~$ 

* Key lesson learned: AWS CLI is case-sensitive 


## using the SDK

- install SDK in the development environment.

cd ~/how-is-your-day/backend
npm install aws-sdk

anju@192 backend % npm install aws-sdk
npm warn deprecated querystring@0.2.0: The querystring API is considered Legacy. new code should use the URLSearchParams API instead.

added 31 packages, and audited 389 packages in 2s

63 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
anju@192 backend %

## creating api endpoints for report generation

### api/generate-report 

was coded and not committed to git waiting to be tested. however test shows error

browser address: 
http://localhost:5001/api/generate-report
result: 
{"success":false,"error":"Internal server error"}

however, api/health returns success. so server is up but new endpoint fails.

i am assuming this is because it is not running on ec2 which has a role to access this object. others do not have perms. however i don't know if it even got to that point.

also, server logs this error multiple times
Unhandled error: [Error: ENOENT: no such file or directory, stat '/Users/anju/Desktop/code/projects/how-is-your-day/frontend/dist/index.html'] {
  errno: -2,
  code: 'ENOENT',
  syscall: 'stat',
  path: '/Users/anju/Desktop/code/projects/how-is-your-day/frontend/dist/index.html',
  expose: false,
  statusCode: 404,
  status: 404
}

- build frontend to avoid  index.html missing comment

- curl and browser window by default use GET whereas this is a POST endpoint. so :

anju@192 week2 % curl -X POST http://localhost:5001/api/generate-report \
     -H "Content-Type: application/json" \
     -d '{"city": "Mumbai"}'
{"success":true,"message":"Daily report generated and stored successfully!","report":{"filename":"mumbai-2025-09-02-1756823610.json","city":"Mumbai","date":"2025-09-02","generated_at":"2025-09-02T14:33:30.946Z","size_bytes":1273,"storage":{"location":"Local","local_path":"/Users/anju/Desktop/code/projects/how-is-your-day/backend/local-reports/mumbai-2025-09-02-1756823610.json","note":"AWS credentials not available - saved to local filesystem"}},"preview":{"current_temp":"27.08°C","weather_desc":"overcast clouds","top_headline":"No news available","forecast_items":8,"news_items":0}}%                                   
anju@192 week2 % 

- on ec2 it didn't work due to some sdk v2 issue. upgrated to sdk v3. first on dev and tested locally. then on ec2

ubuntu@ip-172-31-13-101:~/how-is-your-day/backend$ npm install

added 102 packages, removed 29 packages, changed 4 packages, and audited 461 packages in 4s

52 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities

ubuntu@ip-172-31-13-101:~/how-is-your-day/backend$ nano package.json 
ubuntu@ip-172-31-13-101:~/how-is-your-day/backend$ npm list @aws-sdk/client-s3
weather-news-api@1.0.0 /home/ubuntu/how-is-your-day/backend
└── @aws-sdk/client-s3@3.879.0

- backend works.
- made frontend changes for reports
- did some minor formatting edits in ui. there was a bug in backend which was always searching for india news. fixed



# You've successfully built a complete S3-powered report system with:

- S3 bucket creation and configuration
- AWS SDK v3 integration with proper fallback handling
- Report generation API storing comprehensive weather + news data
- Frontend report generation with success/error states
- Report listing endpoint with metadata parsing
- Individual report retrieval from S3/local storage
- PDF generation and download functionality
- Clean navigation between main app and reports page
