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
