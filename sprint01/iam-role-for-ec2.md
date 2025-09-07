#Quest 3: Configure IAM Role - Let's go!
#Step 1: Create the IAM Role
Go to AWS Console → IAM → Roles → Create Role

Select trusted entity:

Choose "AWS Service"
Select "EC2" (this allows EC2 instances to assume this role)


Attach permissions policies:
attach these policies:

✅ AmazonS3FullAccess (Week 2 prep - you'll store API responses)
✅ AmazonDynamoDBFullAccess (Week 3 prep - user preferences)
✅ CloudWatchLogsFullAccess (Week 5 prep - monitoring)


Role name: weather-app-ec2-role
Description: Role for weather app EC2 to access S3, DynamoDB, and CloudWatch

#Step 2: Attach Role to Your EC2 Instance
Go to EC2 Console → Instances → Select your instance

Actions → Security → Modify IAM Role
Select: weather-app-ec2-role
Update IAM Role

#3. Test
SSH into your EC2 and test:
# Install AWS CLI if not already installed
sudo apt install awscli -y

# Test if your EC2 can now talk to AWS services
aws sts get-caller-identity

# Should show your role ARN, not an error!

ubuntu@ip-172-31-13-101:~$ aws sts get-caller-identity
{
    "UserId": "AROATTI7CLZMMBYDSNE42:i-09e25918b78c2f3e1",
    "Account": "247562657368",
    "Arn": "arn:aws:sts::247562657368:assumed-role/weather-app-ec2-role/i-09e25918b78c2f3e1"
}
ubuntu@ip-172-31-13-101:~$

quest 3 complete