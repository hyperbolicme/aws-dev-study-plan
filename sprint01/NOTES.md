# Week1 Ec2 Iam Ebs

Notes and learnings for this week.

- porting api calls to backend
- moving to ec2 instance

ssh ubuntu@your-server-ip
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
git clone https://github.com/yourusername/your-backend.git
cd your-backend
npm install
npm install -g pm2
pm2 start server.js --name weather-backend
pm2 save
pm2 startup


# nginx
sudo apt install nginx

# at /etc/nginx/sites-available/weather set config
server {
  listen 80;
  server_name yourdomain.com;

  location / {
    proxy_pass http://localhost:3001;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
  }
}

sudo ln -s /etc/nginx/sites-available/weather /etc/nginx/sites-enabled
sudo nginx -t
sudo systemctl restart nginx
