
# Install MySQL client on your EC2
sudo apt update
sudo apt install mysql-client-core-8.0

# Install Node.js MySQL driver in your backend
cd ~/how-is-your-day/backend
npm install mysql2

# edited src/config/database.js to include RDS configurations and apis. for initial testing database name needs to be commented out in .env and in database.js db configuration.

# create the database weatherapp and uncomment above. 

```bash
# First create the database
mysql -h database-how-is-your-day.czkuw6owug4e.ap-south-1.rds.amazonaws.com -u admin -p -e "CREATE DATABASE IF NOT EXISTS weatherapp;"
```

## check for tables

```bash
ubuntu@ip-172-31-13-101:~/how-is-your-day/backend$ mysql -h database-how-is-your-day.czkuw6owug4e.ap-south-1.rds.amazonaws.com -u admin -p weatherapp -e "SHOW TABLES;"
Enter password:
ubuntu@ip-172-31-13-101:~/how-is-your-day/backend$
```

The MySQL connection worked and no tables were shown (empty result), which means the database exists but the tables haven't been created yet.

```bash
# Make sure the database config is correctly pointing to weatherapp
# Uncomment the database line if it's still commented
grep -n "database:" src/config/database.js

# Initialize the database schema
export $(grep -v '^#' .env | xargs) && node -e "
const { initializeDatabase } = require('./src/config/database');
initializeDatabase().then(() => console.log('Tables created successfully')).catch(console.error);
"

ubuntu@ip-172-31-13-101:~/how-is-your-day/backend$ export $(grep -v '^#' .env | xargs) && node -e "
const { initializeDatabase } = require('./src/config/database');
initializeDatabase().then(() => console.log('Tables created successfully')).catch(console.error);
"
Ignoring invalid configuration option passed to Connection: acquireTimeout. This is currently a warning, but in future versions of MySQL2, an error will be thrown if you pass an invalid configuration option to a Connection
Ignoring invalid configuration option passed to Connection: timeout. This is currently a warning, but in future versions of MySQL2, an error will be thrown if you pass an invalid configuration option to a Connection
Ignoring invalid configuration option passed to Connection: reconnect. This is currently a warning, but in future versions of MySQL2, an error will be thrown if you pass an invalid configuration option to a Connection
info: Initializing database schema... {"service":"weather-app","timestamp":"2025-09-17T13:07:43.209Z"}
info: ✅ Database schema initialized successfully {"service":"weather-app","timestamp":"2025-09-17T13:07:43.581Z"}
Tables created successfully

# Check 
ubuntu@ip-172-31-13-101:~/how-is-your-day/backend$ mysql -h database-how-is-your-day.czkuw6owug4e.ap-south-1.rds.amazonaws.com -u admin -p weatherapp -e "SHOW TABLES;"
Enter password: 
+----------------------+
| Tables_in_weatherapp |
+----------------------+
| app_config           |
| city_searches        |
| weather_reports      |
+----------------------+
ubuntu@ip-172-31-13-101:~/how-is-your-day/backend$ 

```

# add a health endpoint for database

```bash
anju@192 sprint03 % curl http://3.110.196.24:5001/api/database-health
{"success":true,"database":{"connection":{"success":true,"message":"Database connected successfully"},"tables":{"app_config":{"config_count":3},"weather_reports":{"reports_count":0},"city_searches":{"cities_count":0}},"sample_config":[{"config_key":"default_city","config_value":"Kochi","config_type":"string","description":"Default city for new users","updated_at":"2025-09-17T13:07:43.000Z"},{"config_key":"enable_analytics","config_value":"true","config_type":"boolean","description":"Enable usage analytics tracking","updated_at":"2025-09-17T13:07:43.000Z"},{"config_key":"reports_retention_days","config_value":"365","config_type":"number","description":"Number of days to keep weather reports","updated_at":"2025-09-17T13:07:43.000Z"}],"rds_endpoint":"database-how-is-your-day.czkuw6owug4e.ap-south-1.rds.amazonaws.com","database_name":"weatherapp"},"timestamp":"2025-09-17T13:43:05.123Z"}%                      anju@192 sprint03 % 
```

btw backend cannot be tested on dev machine because of database permission issues

# changed report services to add logic for saving metadata in DB