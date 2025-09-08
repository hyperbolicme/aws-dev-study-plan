# 🚀 Backend Refactoring Migration Guide

## Overview

This guide will help you migrate from your monolithic `server.js` to a clean, modular, and well-tested backend architecture.

## 📋 Pre-Migration Checklist

- [ ] Backup your current `server.js` file
- [ ] Ensure your current backend is working
- [ ] Have Node.js 18+ installed
- [ ] Have your environment variables ready (`.env` file)

## 🎯 Step 1: Install Dependencies

```bash
cd backend

# Install testing dependencies
npm install --save-dev jest supertest @types/jest nodemon

# Install additional production dependencies
npm install joi winston helmet express-rate-limit

# Verify installation
npm list jest supertest joi winston
```

## 🏗️ Step 2: Create Directory Structure

```bash
# Create the new modular structure
mkdir -p src/{config,middleware,services,controllers,routes,utils}
mkdir -p tests/{unit,integration,fixtures}

# Verify structure
tree src tests
```

## 📁 Step 3: Migration Order (IMPORTANT!)

**Follow this exact order to avoid dependency issues:**

### Phase 1: Foundation (Day 1)
1. **Environment & Config**
   - Copy `src/config/environment.js`   √
   - Copy `src/config/database.js`      √
   - Update your `.env` file if needed  √

2. **Utilities**
   - Copy `src/utils/constants.js`      √
   - Copy `src/utils/logger.js`         √
   - Copy `src/utils/validators.js`     √

3. **Test Setup**
   - Copy `jest.config.js`              √
   - Copy `tests/setup.js`              √
   - Copy `tests/fixtures/mockData.js`  √

### Phase 2: Core Services (Day 2)
4. **Services Layer**
   - Copy `src/services/cacheService.js`
   - Copy `src/services/weatherService.js`
   - Copy `src/services/newsService.js`
   - Copy `src/services/s3Service.js`
   - Copy `src/services/reportService.js`

### Phase 3: API Layer (Day 3)
5. **Middleware**
   - Copy `src/middleware/cors.js`
   - Copy `src/middleware/errorHandler.js`
   - Copy `src/middleware/validation.js`

6. **Controllers**
   - Copy `src/controllers/weatherController.js`
   - Copy `src/controllers/newsController.js`
   - Copy `src/controllers/reportController.js`
   - Copy `src/controllers/healthController.js`

7. **Routes**
   - Copy `src/routes/weather.js`
   - Copy `src/routes/news.js`
   - Copy `src/routes/reports.js`
   - Copy `src/routes/health.js`
   - Copy `src/routes/index.js`

### Phase 4: Main Server (Day 4)
8. **New Server**
   - **BACKUP** your original `server.js` as `server.js.backup`
   - Copy the new `src/server.js`

9. **Package.json Updates**
   - Update your scripts section:
   ```json
   {
     "scripts": {
       "start": "node src/server.js",
       "dev": "nodemon src/server.js", 
       "test": "jest",
       "test:watch": "jest --watch",
       "test:coverage": "jest --coverage"
     }
   }
   ```

## 🧪 Step 4: Run Tests

```bash
# Run unit tests
npm run test:unit

# Run integration tests  
npm run test:integration

# Run all tests
npm test

# Run with coverage
npm run test:coverage
```

## ⚡ Step 5: Test the Refactored Server

```bash
# Start the new server
npm run dev

# Test endpoints
curl http://localhost:5001/api/health
curl "http://localhost:5001/api/getweather?city=Mumbai"
curl "http://localhost:5001/api/getnews?country=in"

# Test report generation
curl -X POST http://localhost:5001/api/generate-report \
  -H "Content-Type: application/json" \
  -d '{"city": "Mumbai", "country": "IN"}'
```

## 🔄 Step 6: Environment Variables

Make sure your `.env` file has all required variables:

```env
# Required
WEATHER_API_KEY=your_openweather_api_key
PORT=5001

# Optional (for news features)
NEWS_API_KEY=your_news_api_key
NEWS_GUARDIAN_API_KEY=your_guardian_api_key

# Frontend (if applicable)
FRONTEND_URL=http://localhost:3000
```

## 🚨 Troubleshooting Common Issues

### Issue 1: Import/Export Errors
```bash
# Error: Cannot find module './config/environment'
# Solution: Make sure you copied all files in the correct order
```

### Issue 2: Tests Failing
```bash
# Run tests with verbose output
npm test -- --verbose

# Check if all mock files are in place
ls tests/fixtures/
```

### Issue 3: Server Won't Start
```bash
# Check for missing dependencies
npm install

# Verify environment variables
cat .env

# Check logs
npm run dev 2>&1 | head -20
```

### Issue 4: Routes Not Working
```bash
# Verify route mounting in src/routes/index.js
# Check middleware order in src/server.js
```

## 📊 Verification Checklist

After migration, verify these work:

- [ ] Server starts without errors
- [ ] Health check: `GET /api/health`
- [ ] Weather API: `GET /api/getweather?city=Mumbai`
- [ ] News API: `GET /api/getnews?country=in`
- [ ] Report generation: `POST /api/generate-report`
- [ ] Report listing: `GET /api/my-reports`
- [ ] S3 test: `GET /api/test-s3`
- [ ] All tests pass: `npm test`

## 🎉 Benefits After Migration

### 1. **Modularity**
- Each component has a single responsibility
- Easy to modify individual features
- Better code organization

### 2. **Testability**
- Comprehensive unit tests
- Integration tests for API endpoints
- Test coverage reports

### 3. **Maintainability**
- Clear separation of concerns
- Standardized error handling
- Consistent validation

### 4. **Scalability**
- Easy to add new endpoints
- Services can be reused
- Better caching strategy

### 5. **Developer Experience**
- Better debugging with structured logging
- Input validation with clear error messages
- Rate limiting and security headers

## 🔄 Rollback Plan

If something goes wrong:

```bash
# Stop the new server
pm2 delete weather-api

# Restore original server
cp server.js.backup server.js

# Start original server
pm2 start server.js --name weather-api
```

## 📈 Next Steps

1. **Week 3**: Add more comprehensive logging
2. **Week 4**: Implement API versioning
3. **Week 5**: Add more detailed monitoring
4. **Week 6**: Consider microservices architecture

## 💡 Tips for Success

1. **Test each phase** before moving to the next
2. **Keep your original server.js** as backup
3. **Run tests frequently** during migration
4. **Check logs** for any errors or warnings
5. **Test on your EC2 instance** after local testing

## 🆘 Getting Help

If you encounter issues:

1. Check the error logs carefully
2. Verify all files are copied correctly
3. Ensure environment variables are set
4. Run tests to identify specific issues
5. Compare with the working original if needed

---

**Remember**: This refactoring maintains 100% API compatibility while dramatically improving code quality and maintainability! 🎯