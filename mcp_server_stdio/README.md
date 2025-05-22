# MCP Server Stdio

## Overview
The `mcp_server_stdio` project is a Model Context Protocol (MCP) server that provides tools for various functionalities, such as calculating BMI and fetching weather data for a city. It uses the Stdio transport for communication.

## Features
- **Calculate BMI**: Computes the Body Mass Index (BMI) based on weight and height.
- **Fetch Weather**: Retrieves weather information for a specified city using the OpenWeatherMap API.

## Setup Instructions
1. Clone the repository:
   ```bash
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```bash
   cd mcp_server_stdio
   ```
3. Install dependencies:
   ```bash
   npm install
   ```
4. Set up the required environment variable:
   - `OPEN_WEATHER_MAP_API_KEY`: Your API key for the OpenWeatherMap service.

## Usage
1. Start the server:
   ```bash
   npm start
   ```
2. Use the following tools:
   - **Calculate BMI**:
     - Input: `weightKg` (number), `heightM` (number)
     - Output: BMI value.
   - **Fetch Weather**:
     - Input: `city` (string)
     - Output: Weather details including temperature, conditions, humidity, and wind information.

## Environment Variables
- `OPEN_WEATHER_MAP_API_KEY`: Obtain an API key from [OpenWeatherMap](https://openweathermap.org/api) and set it in your environment to enable the weather fetching functionality.

## License
This project is licensed under the MIT License.