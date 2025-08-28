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

