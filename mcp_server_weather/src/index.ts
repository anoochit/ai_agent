import express, { Request, Response } from "express";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { SSEServerTransport } from "@modelcontextprotocol/sdk/server/sse.js";

import { z } from "zod";
import { hostname } from "os";

const BASE_URL = "https://api.openweathermap.org/data/2.5/weather";
const OPEN_WEATHER_MAP_API_KEY = process.env.OPEN_WEATHER_MAP_API_KEY;

// Create server instance
const server = new McpServer({
  name: "mcp-city-weather",
  version: "1.1.0",
  capabilities: {
    tools: {},
  },
});

// Weather interfaces
export interface CityWeather {
  coord: Coord;
  weather: Weather[];
  base: string;
  main: Main;
  visibility: number;
  wind: Wind;
  clouds: Clouds;
  dt: number;
  sys: Sys;
  timezone: number;
  id: number;
  name: string;
  cod: number;
}

export interface Clouds {
  all: number;
}

export interface Coord {
  lon: number;
  lat: number;
}

export interface Main {
  temp: number;
  feels_like: number;
  temp_min: number;
  temp_max: number;
  pressure: number;
  humidity: number;
  sea_level?: number;
  grnd_level?: number;
}

export interface Sys {
  type: number;
  id: number;
  country: string;
  sunrise: number;
  sunset: number;
}

export interface Weather {
  id: number;
  main: string;
  description: string;
  icon: string;
}

export interface Wind {
  speed: number;
  deg: number;
  gust?: number;
}

// Converts JSON strings to/from your types
export class Convert {
  public static toCityWeather(json: string): CityWeather {
    return JSON.parse(json);
  }

  public static cityWeatherToJson(value: CityWeather): string {
    return JSON.stringify(value);
  }
}

// Register tools
server.tool(
  "calculate_bmi",
  "Calculate Body Mass Index (BMI) from weight and height",
  {
    weightKg: z.number(),
    heightM: z.number(),
  },
  async ({ weightKg, heightM }) => ({
    content: [
      {
        type: "text",
        text: 'BMI = ' + (weightKg / (heightM * heightM)).toFixed(2) + '\n',
      },
    ],
  })
);

server.tool(
  "fetch_weather",
  "Get weather forecast for a city",
  { city: z.string().describe("City name") },
  async ({ city }) => {
    if (!city) {
      return {
        content: [
          {
            type: "text",
            text: "No city provided",
          },
        ],
      };
    }

    if (!OPEN_WEATHER_MAP_API_KEY) {
      return {
        content: [
          {
            type: "text",
            text: "API key is not configured. Please set the OPEN_WEATHER_MAP_API_KEY environment variable.",
          },
        ],
      };
    }

    // fetch data
    try {
      const response = await fetch(
        `${BASE_URL}?q=${encodeURIComponent(
          city
        )}&units=metric&appid=${OPEN_WEATHER_MAP_API_KEY}`
      );

      if (!response.ok) {
        return {
          content: [
            {
              type: "text",
              text: `Error fetching weather data: ${response.status} ${response.statusText}`,
            },
          ],
        };
      }

      const weatherData: CityWeather = await response.json();

      // Format the response in a user-friendly way
      const friendlyFormattedWeather = `
      Weather for ${weatherData.name}, ${weatherData.sys.country}:
      Temperature: ${weatherData.main.temp}°C (feels like ${weatherData.main.feels_like}°C)
      Conditions: ${weatherData.weather[0].main} - ${weatherData.weather[0].description}
      Humidity: ${weatherData.main.humidity}%
      Wind: ${weatherData.wind.speed} m/s, direction: ${weatherData.wind.deg}°
            `.trim();

      const formattedWeather = `[ ${Convert.cityWeatherToJson(weatherData)} ]`;

      return {
        content: [
          // {
          //   type: "text",
          //   text: formattedWeather,
          // },
          {
            type: "text",
            text: friendlyFormattedWeather,
          },
        ],
      };
    } catch (error) {
      return {
        content: [
          {
            type: "text",
            text: `Failed to fetch weather data: ${error instanceof Error ? error.message : String(error)
              }`,
          },
        ],
      };
    }
  }
);

// Start the server
const app = express();

// to support multiple simultaneous connections we have a lookup object from
// sessionId to transport
const transports: { [sessionId: string]: SSEServerTransport } = {};

app.get("/sse", async (_: Request, res: Response) => {
  const transport = new SSEServerTransport("/messages", res);
  transports[transport.sessionId] = transport;
  res.on("close", () => {
    delete transports[transport.sessionId];
  });
  await server.connect(transport);
});

app.post("/messages", async (req: Request, res: Response) => {
  const sessionId = req.query.sessionId as string;
  const transport = transports[sessionId];
  if (transport) {
    await transport.handlePostMessage(req, res);
  } else {
    res.status(400).send("No transport found for sessionId");
  }
});

app.listen(3000);
