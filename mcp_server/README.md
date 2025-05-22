# MCP City Weather Server

This project is an implementation of an MCP (Model Context Protocol) server that provides tools for calculating BMI and fetching weather data for a given city. It uses the OpenWeatherMap API to fetch weather information.

## Features

- **Calculate BMI**: A tool to calculate Body Mass Index (BMI) based on weight and height.
- **Fetch Weather**: A tool to fetch weather information for a specified city using the OpenWeatherMap API.

## Prerequisites

- Node.js (v16 or later)
- An OpenWeatherMap API key. You can obtain one by signing up at [OpenWeatherMap](https://openweathermap.org/).

## Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd mcp_server
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up environment variables:
   Create a `.env` file in the root directory and add your OpenWeatherMap API key:
   ```env
   OPEN_WEATHER_MAP_API_KEY=your_api_key_here
   ```

## Running the Server

1. Start the server:
   ```bash
   npm start
   ```

2. The server will be available at `http://localhost:3000`.

## API Endpoints

### `/sse`
- **Method**: GET
- **Description**: Establishes an SSE (Server-Sent Events) connection.

### `/messages`
- **Method**: POST
- **Description**: Handles messages for a specific session.
- **Query Parameters**:
  - `sessionId`: The session ID for the transport.

## Tools

### Calculate BMI
- **Name**: `calculate_bmi`
- **Description**: Calculates BMI from weight and height.
- **Input**:
  - `weightKg`: Weight in kilograms (number).
  - `heightM`: Height in meters (number).
- **Output**: BMI value.

### Fetch Weather
- **Name**: `fetch_weather`
- **Description**: Fetches weather information for a city.
- **Input**:
  - `city`: Name of the city (string).
- **Output**: Weather details including temperature, conditions, humidity, and wind information.

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.