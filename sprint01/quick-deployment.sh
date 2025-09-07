# Build frontend
cd frontend && npm run build

# Start backend with PM2
cd ../backend 
# Stop any running PM2 processes
pm2 delete weather-api

# Load environment variables
export $(cat .env | xargs)

# Verify they're loaded
echo $WEATHER_API_KEY

# Start PM2 (it will inherit the environment)
pm2 start server.js --name weather-api

# Save configuration
pm2 save

# Setup auto-startup
pm2 startup