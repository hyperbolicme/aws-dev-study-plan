# See your current storage costs

```bash
aws s3api list-objects-v2 --bucket weather-app-reports-hyperbolicme --query 'sum(Contents[].Size)'
```

# Set up intelligent tiering

```bash
aws s3api put-bucket-lifecycle-configuration --bucket weather-app-reports-hyperbolicme --lifecycle-configuration '{
  "Rules": [{
    "ID": "WeatherReportsLifecycle",
    "Status": "Enabled",
    "Filter": {"Prefix": "reports/"},
    "Transitions": [
      {
        "Days": 30,
        "StorageClass": "STANDARD_IA"
      },
      {
        "Days": 90, 
        "StorageClass": "GLACIER"
      },
      {
        "Days": 365,
        "StorageClass": "DEEP_ARCHIVE"
      }
    ]
  }]
}'
```


# Enable versioning (rollback protection!)

```bash
aws s3api put-bucket-versioning --bucket how-is-your-day-frontend-hyperbolicme --versioning-configuration Status=Enabled
```

# List all versions of a file

```bash
aws s3api list-object-versions --bucket how-is-your-day-frontend-hyperbolicme --prefix index.html
```
enabled versioning and did a new deploy. after that, this command resulted in multiple entries 

```json
{
    "Versions": [
        {
            "ETag": "\"cf60f9c85101189e04c6325fa8d844af\"",
            "Size": 824,
            "StorageClass": "STANDARD",
            "Key": "index.html",
            "VersionId": "HmLVAlibwxX0ib5vfFMPnx9MDyKZ8Wkz",
            "IsLatest": true,
            "LastModified": "2025-09-09T14:29:10.000Z",
            "Owner": {
                "ID": "d2e176205edbb52776d23a5bc1066dae7535ba99d5725a7e4f3be4b2cf2ee162"
            }
        },
        {
            "ETag": "\"cf60f9c85101189e04c6325fa8d844af\"",
            "Size": 824,
            "StorageClass": "STANDARD",
            "Key": "index.html",
            "VersionId": "null",
            "IsLatest": false,
            "LastModified": "2025-09-09T09:45:16.000Z",
            "Owner": {
                "ID": "d2e176205edbb52776d23a5bc1066dae7535ba99d5725a7e4f3be4b2cf2ee162"
            }
        }
    ]
}

```


# Rollback to previous version if deployment breaks

```bash
aws s3api copy-object --bucket how-is-your-day-frontend-hyperbolicme --copy-source "bucket/index.html?versionId=PREVIOUS_VERSION_ID" --key index.html
```


# Find all reports from specific cities

```bash
aws s3api list-objects-v2 --bucket weather-app-reports-hyperbolicme --query "Contents[?contains(Key, 'mumbai')]"
```

```bash
ubuntu@ip-172-31-13-101:~$ aws s3api list-objects-v2 --bucket weather-app-reports-hyperbolicme --query "Contents[?contains(Key, 'mumbai')]"
[
    {
        "Key": "reports/default_user/mumbai-2025-09-02-1756831130.json",
        "LastModified": "2025-09-02T16:38:51.000Z",
        "ETag": "\"51114c95738b0438d70defeb2efea001\"",
        "Size": 1860,
        "StorageClass": "STANDARD"
    },
    {
        "Key": "reports/user123/mumbai-2025-09-02-1756829942.json",
        "LastModified": "2025-09-02T16:19:03.000Z",
        "ETag": "\"a660c5b208d94b44215a7ff03919cdd1\"",
        "Size": 1860,
        "StorageClass": "STANDARD"
    }
]

ubuntu@ip-172-31-13-101:~$ aws s3api list-objects-v2 --bucket weather-app-reports-hyperbolicme --query "length(Contents[?contains(Key, 'kochi')])"
55

ubuntu@ip-172-31-13-101:~$ aws s3api list-objects-v2 --bucket weather-app-reports-hyperbolicme --query "Contents[?contains(Key, 'kochi')]" | jq length
55

ubuntu@ip-172-31-13-101:~$ # Get all unique cities from your reports
aws s3api list-objects-v2 --bucket weather-app-reports-hyperbolicme --query "Contents[].Key" --output text | grep -o '[^/]*\.json' | sed 's/-[0-9]*-[0-9]*-[0-9]*\.json//' | sort | uniq -c
      1 bangalore-2025
      3 cape town-2025
      1 chennai -2025
      1 chennai-2025
      7 chicago-2025
      1 cochin-2025
      1 delhi-2025
      1 hyderabad-2025
      1 johannesburg-2025
     55 kochi-2025
      2 mumbai-2025
      1 new york city-2025
      4 new york-2025
      2 paris-2025
      4 san francisco-2025
      1 san jose-2025
      1 tokyo-2025
      6 tripoli-2025
      1 trivandrum-2025
ubuntu@ip-172-31-13-101:~$ 

```


# Reports from last 7 days

```bash
aws s3api list-objects-v2 --bucket weather-app-reports-hyperbolicme --query "Contents[?LastModified>=\`$(date -d '7 days ago' -Iso)\`]"

ubuntu@ip-172-31-13-101:~$ ubuntu@ip-172-31-13-101:~$ aws s3api list-objects-v2 --bucket weather-app-reports-hyperbolicme --query "Contents[?LastModified>=\`$(date -d '1 days ago' -I)\`]"
[
    {
        "Key": "reports/default_user/san jose-2025-09-09-1757385069.json",
        "LastModified": "2025-09-09T02:31:10.000Z",
        "ETag": "\"e316cd360a531ba1aca68fabc4fa11e3\"",
        "Size": 4299,
        "StorageClass": "STANDARD"
    },
    {
        "Key": "reports/default_user/trivandrum-2025-09-09-1757421609.json",
        "LastModified": "2025-09-09T12:40:10.000Z",
        "ETag": "\"5e02857b92ec1bb6a142a2caf2577104\"",
        "Size": 1366,
        "StorageClass": "STANDARD"
    }
]
ubuntu@ip-172-31-13-101:~$ 

```
# Download all reports and analyze weather trends

```bash
aws s3 sync s3://weather-app-reports-hyperbolicme/reports/ ./reports-analysis/
```
# Find your most active reporting days

```bash
aws s3api list-objects-v2 --bucket weather-app-reports-hyperbolicme --query "Contents[].LastModified" | jq -r '.[]' | cut -d'T' -f1 | sort | uniq -c | sort -nr

ubuntu@ip-172-31-13-101:~$ aws s3api list-objects-v2 --bucket weather-app-reports-hyperbolicme --query "Contents[].LastModified" | jq -r '.[]' | cut -d'T' -f1 | sort | uniq -c | sort -nr
     61 2025-09-03
     14 2025-09-07
     10 2025-09-06
      8 2025-09-02
      2 2025-09-09
ubuntu@ip-172-31-13-101:~$ 
```