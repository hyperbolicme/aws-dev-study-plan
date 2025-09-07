# week 1 consolidation

## creating an EC2 instance

Follow the lectures.

## design choices

* not containarising for now. Docker adds complexity unnecessaery for AWS prep and portfolio
* not using Vercel for deployment (although it does hot update when GitHub is updated), again, because of necessary complexity. the complexity being that it uses HTTPS traffic and that rabbithole leads to CloudFlare setup etc
* we will host both frontend and backend in the same EC2 box. Vite will be out of the picture in this case, backend will host frontend.

## Logging into EC2

`chmod 400 hiyd-backend-keys.pem` # first time. created when creating the instance in aws console.
`ssh -i hiyd-backend-keys.pem ubuntu@<ec2 instance ip>`

## hosting frontend and backend

### First time installs

Node 18+, Git, PM2

`sudo apt update`
`sudo apt install -y git`
`sudo npm install -g pm2`

## Hosting on EC2

1. get/update code from git
2. build frontend
3. add code in backend to serve frontend dist folder
4. run server on PM2

* get code from Git.

 
`git clone https://github.com/<your-username>/<your-backend-repo>.git`

first time. for updates, `git pull origin main`

### Note this must be added to backend server.js (one time)

Add this to your server.js (BEFORE your API routes):

`const path = require('path');`

`// Serve static files from React build
app.use(express.static(path.join(__dirname, '../frontend/dist')));`

Add this AFTER all route definitions

`// the following at LAST after all api routes
// Handle React routing (add this AFTER all API routes)
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../frontend/dist', 'index.html'));
});`


### Build frontend

in .env give ip:port of server. then build.

ex:

`VITE_API_BASE_URL=http://3.110.28.176:5001`

build:

`cd frontend && npm run build`

### Start backend with PM2

`cd ../backend`

### Stop any running PM2 processes

`pm2 delete weather-api`


### Load environment variables

`export $(cat .env | xargs)`

### Verify they're loaded (optional)

`echo $WEATHER_API_KEY`

### Start PM2 (it will inherit the environment)

`pm2 start server.js --name weather-api`

### Save configuration (first time)

`pm2 save`

### Setup auto-startup (first time)

`sudo pm2 startup`

## Hosted URLs

Frontend: http://ec2_ip:5001/
API: http://ec2_ip:5001/api/health

change 5001 to whatever port server is listening on, if needed.

## Ensure 5001/port is added to security group of ec2.


# Using EBS

EBS has to be in same AZ as the EC2 instance. Find this AZ.
See lectures for details.

### Create EBS volume

Find AZ of ec2 instance. Console details gives Region only.

`aws ec2 describe-instances \
  --instance-ids i-09e25918b78c2f3e1 \
  --query "Reservations[].Instances[].Placement.AvailabilityZone" \
  --output text \
  --region ap-south-1` # region from console. 

make sure new volume is same AZ

### Attach volume to EC2 instance

open volume > Actions > Attach volume. 

Check

`ubuntu@ip-172-31-13-101:~$ lsblk`

ex:

`nvme1n1      259:4    0    5G  0 disk`  ---> seems to be the new volume

### format volume before use (first time)

`ubuntu@ip-172-31-13-101:~$ sudo mkfs -t ext4 /dev/nvme1n1`

### mount the volume

`ubuntu@ip-172-31-13-101:~$ sudo mkdir /mnt/data
ubuntu@ip-172-31-13-101:~$ sudo mount /dev/nvme1n1 /mnt/data`

verify:

`ubuntu@ip-172-31-13-101:~$ df -h`

### persist mount across reboots

add volume to `/etc/fstab`. 

#### get UUID 

`ubuntu@ip-172-31-13-101:~$ sudo blkid /dev/nvme1n1`

#### add to fstab

add the following to /etc/fstab

`UUID=fad0b8b0-a3fc-42ea-ad20-b0390b6d9d01   /mnt/data   ext4   defaults,nofail   0   2`


### give ubuntu (user) permission to write to new mount

`ubuntu@ip-172-31-13-101:~/how-is-your-day/backend$ sudo chmod 755 /mnt/data
ubuntu@ip-172-31-13-101:~/how-is-your-day/backend$ sudo chown ubuntu:ubuntu /mnt/data`

