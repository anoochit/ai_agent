# MCP Client

This project demonstrates how to use the Model Context Protocol (MCP) client to connect to an MCP server and interact with tools provided by the server.

## Features
- Connects to an MCP server using SSE (Server-Sent Events) transport.
- Demonstrates calling a tool (e.g., fetching weather data).

## Prerequisites
- Node.js (v16 or later)
- MCP server running at `http://localhost:3000/sse`

## Installation
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd mcp_client
   ```
2. Install dependencies:
   ```bash
   npm install
   ```

## Usage
1. Start the MCP server if not already running.
2. Run the client:
   ```bash
   npm start
   ```

## Example
The following example demonstrates fetching weather data for Bangkok:

```typescript
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { SSEClientTransport } from "@modelcontextprotocol/sdk/client/sse.js";

const client = new Client({
  name: "example-client",
  version: "1.0.0",
});

const transport = new SSEClientTransport(new URL("http://localhost:3000/sse"));
await client.connect(transport);

const result = await client.callTool({
  name: "fetch_weather",
  arguments: {
    city: "bangkok",
  },
});

console.log("Weather result:", result);
client.close();
```

## License
This project is licensed under the MIT License. See the LICENSE file for details.