# Ideas for adv CLI
this is a side quest

Side-side quest - create endpoints to identify server. 4 endpoints added. after testing will decide to keep one. added them in health controller and route files

## Deployment Automation:

### Script the entire deployment process: build frontend, sync to S3, restart backend services [√]	

- how-is-your-day utils has the deploy.sh. has options to do default deploy from existing git repository OR to specify a new folder to be created for a fresh deploy with env vars configured afresh.

and heath-check.sh

### Automate environment configuration across dev/staging/production [NA]
### Create scripts for rolling back deployments if issues arise [not now]

## Monitoring and Maintenance:

### CLI scripts to check application health across all services (EC2, S3, CloudFront) [√]
### Automated log collection and analysis from your EC2 instance???
### Scripts to backup your S3 reports and database???

## Development Workflow:[NA]

### Automate the build-test-deploy cycle you've established
### Scripts to quickly spin up new environments for testing???
### Automated cleanup of old S3 objects or unused resources

## Infrastructure Management:[NA]

### Scripts to scale your EC2 instance up/down based on usage???
### Automate security group updates when you add new services???
### Cost monitoring scripts to track your AWS spending???

## Data Management???[NA]

### Bulk operations on your weather reports stored in S3
### Scripts to migrate data between environments
### Automated data validation and cleanup



## Testing scripts that verify global accessibility:

### Scripts that test your deployment from multiple regions
### Automated checks that validate both S3 and CloudFront endpoints
