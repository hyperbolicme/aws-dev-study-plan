
# s3 bucket creation for reports

done

# backend refactoring & testing

backend refactored from a single 800+ line file to logically separated 25 files. added ~130 unit tests

# CloudFront as CDN for frontend

- create a bucket. we will use "how-is-your-day-frontend-hyperbolicme" with Block All Public access checkbox unchecked under Permissions so that it can be opened for public access. this option when checked overrides any public access iirc.
- add a bucket policy to Allow all (asterix) S3 Get Object access to all objects in the above bucket via policy generator
```json 
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Statement1",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::how-is-your-day-frontend-hyperbolicme/*"
        }
    ]
}
```
- previous two steps (bucket policy & setting as static site) can be done via CLI as well after bucket is created
```bash
# Enable static website hosting
aws s3 website s3://how-is-your-day-frontend-hyperbolicme/ --index-document index.html --error-document index.html

# Make files publicly readable (needed for CloudFront)
aws s3api put-bucket-policy --bucket how-is-your-day-frontend-hyperbolicme --policy '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::how-is-your-day-frontend-hyperbolicme/*"
    }
  ]
}'
```

- now in the deployment process, instead of keeping the dist folder of the frontend build in ec2, it is added to the s3 bucket. in other words

```bash
cd frontend
npm run build
aws s3 sync dist/ s3://how-is-your-day-frontend-hyperbolicme/ --delete

# Verify upload
aws s3 ls s3://how-is-your-day-frontend-hyperbolicme/
```

- backend deploy remains the same

- view the webapp at the s3 bucket url - http://how-is-your-day-frontend-hyperbolicme.s3-website.ap-south-1.amazonaws.com

-- we got some CORS issue here because the expected traffic at the api endpoints is not expected from amazonaws.com

# CDN using CloudFront

- create a CloudFront distribution with origin as the s3 static website and protocol as HTTP only. takes a few minutes to deploy
```bash
# Check distribution status
aws cloudfront list-distributions --query 'DistributionList.Items[?Comment==`How Is Your Day Frontend CDN`].[Id,Status,DomainName]' --output table
```

the cloudfront url should also be added to cors middleware

- cloudfront uses https but api endpoint calls are http. so they are getting blocked. 
```
[Warning] [blocked] The page at https://d2qr9yt8ob8ckr.cloudfront.net/ requested insecure content from http://3.110.196.24:5001/api/getnews-combined?country=IN&pageSize=10. This content was blocked and must be served over HTTPS. (index-s7z0bG2K.js, line 174)
```
to fix this ec2 should serve on https. ie ssl certification etc. will see that tomorrow




