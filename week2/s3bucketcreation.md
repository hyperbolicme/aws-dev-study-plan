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






