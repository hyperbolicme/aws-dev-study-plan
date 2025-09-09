# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

"How is your day" is a weather and news application with a React frontend and Node.js/Express backend. The backend serves as both an API server and serves the built React application in production.

## Architecture

### Backend (`/backend`)
- **Main Entry**: `server.js` - Express server with comprehensive caching system
- **API Endpoints**: 
  - Weather: `/api/getweather`, `/api/getforecast` (OpenWeatherMap)
  - News: `/api/getnews` (NewsAPI), `/api/getnews-guardian` (Guardian), `/api/getnews-combined` (fallback logic)
  - Health: `/api/health`
- **Caching**: File-based caching with 30-minute TTL, supports both local (`cache/`) and EBS (`/mnt/data/cache`) storage
- **Static Serving**: Serves built React app from `../frontend/dist` for production
- **Environment**: Requires `WEATHER_API_KEY`, optional `NEWS_API_KEY` and `NEWS_GUARDIAN_API_KEY`

### Frontend (`/frontend`)
- **Framework**: React 19 + Vite build system
- **Styling**: Tailwind CSS with custom color themes (teal/green, blue, hero colors)
- **Animation**: GSAP with React integration (`@gsap/react`)
- **Components**: Weather sections, news sections, search functionality, loading animations
- **Icons**: Lucide React
- **Main Entry**: `src/main.jsx` → `src/WeatherNewsApp.jsx` (App.jsx is commented out)

## Development Commands

### Backend
- `npm run dev` - Start with nodemon (auto-reload)
- `npm start` - Production start
- `npm test` - Run Jest tests

### Frontend  
- `npm run dev` - Start Vite dev server
- `npm run build` - Build for production
- `npm run lint` - ESLint validation
- `npm run preview` - Preview production build

## Key Configuration Files

- **Backend**: `package.json`, `.env` (API keys), `server.js` (main logic)
- **Frontend**: `package.json`, `vite.config.js`, `tailwind.config.js`, `eslint.config.js`
- **Styling**: Custom Tailwind theme with specific color palettes and fonts (Merriweather, Montserrat, Poiret One)

## Development Workflow

1. **Environment Setup**: Ensure `.env` files are configured in both directories
2. **Backend First**: Start backend server (`npm run dev` in `/backend`) 
3. **Frontend Development**: Start frontend dev server (`npm run dev` in `/frontend`)
4. **Production**: Backend serves frontend build automatically when accessing non-API routes

## Caching Strategy

The backend implements intelligent caching that:
- Uses local filesystem in development
- Switches to EBS storage in production
- 30-minute cache duration for all API responses
- MD5-based cache keys for consistency

## API Integration

- Weather data from OpenWeatherMap API
- News from multiple sources with fallback logic (Guardian → NewsAPI)
- All responses include success/error status and timestamp
- Comprehensive error handling for external API failures