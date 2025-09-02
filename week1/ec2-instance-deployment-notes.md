chmod 400 hiyd-backend-keys.pem
ssh -i hiyd-backend-keys.pem ubuntu@3.110.28.176


# logged in to ec2
# install docker

sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

#On your local machine (not EC2 yet), inside your backend project, create a #Dockerfile (see github for contents)
#.dockerignore (same)

# test locally in backend folder
docker build -t weather-backend .
docker run -p 3001:3001 weather-backend

#http://localhost:5001/api/health should say success

#push docker image to dockerhub

docker login
docker tag weather-backend your-dockerhub-username/weather-backend
docker push your-dockerhub-username/weather-backend

#Run on EC2
sudo docker run -d -p 80:3001 your-dockerhub-username/weather-backend


#this will result in arm vs amd architechture mismatch coz built in mac and trying
#trying to run in amd linux. so build in ec2

sudo apt update && sudo apt install -y git
git clone https://github.com/<your-username>/<your-backend-repo>.git
cd <your-backend-repo>

sudo docker build -t weather-backend .
sudo docker run -d -p 80:5000 weather-backend

curl http://localhost/api/hello

#if curl fails, port mapping could be issue. check logs

docker ps -a 			# check docker container id
docker logs <id>

# verify the ports are different. stop and kill container

docker stop <id>
docker rm <id>


docker run -d -p 80:<correct port> weather-backend

curl http://localhost/api/hello

# on mac
curl "http://3.110.28.176/api/getweather?city=kochi" #quotes so zshell doesn't misinterpret 


# https issue. vercel uses https, need to serve backend over https

# Update package list
sudo apt update

# Download & install cloudflared
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb
sudo dpkg -i cloudflared.deb

# Verify
cloudflared --version

cloudflared tunnel login

cloudflared tunnel --url http://localhost:80

#copy the on-demand domain name and add to env under API_URL

#this is what is happening:

Internet (Vercel/Browser over HTTPS)
        │
        ▼
Cloudflare Tunnel (cloudflared on EC2)
        │  (targets host port 80)
        ▼
EC2 Host :80  ──► Docker NAT mapping ──► Container :5001
                        (-p 80:5001)
        │                                   │
        │                                   ▼
        │                         Node/Express listening on 5001
        └────────────────────────────────────────────────────────

#vercel is adding unnecessary complications. will stick to hosting the frontend locally on mac. therefore avoiding the whole cloudflare nonsense

#removed Docker from workflow. which arises another issue ie keeping server alive even after the ssh session has ended. Use pm2 which is the industry standard for node deployments

cd /home/ubuntu/how-is-your-day/backend
sudo npm install -g pm2
pm2 start server.js --name weather-api
pm2 save
sudo pm2 startup

#works!

#serving frontend also in the same instance

frontend$ npm run build # creates a dist folder to host

#Add this to your server.js (before your API routes):
const path = require('path');

// Serve static files from React build

app.use(express.static(path.join(__dirname, '../frontend/dist')));

// the following at LAST after all api routes
// Handle React routing (add this AFTER all API routes)

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../frontend/dist', 'index.html'));
});


cd ~/how-is-your-day/backend
pm2 restart weather-api

Frontend: http://3.110.28.176:5001/
API: http://3.110.28.176:5001/api/health