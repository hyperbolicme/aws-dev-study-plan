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

### Save configuration

`pm2 save`

### Setup auto-startup

`sudo pm2 startup`

# Hosted URLs

Frontend: http://ec2_ip:5001/
API: http://ec2_ip:5001/api/health

change 5001 to whatever port server is listening on, if needed.