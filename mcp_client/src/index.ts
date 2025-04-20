import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { SSEClientTransport } from "@modelcontextprotocol/sdk/client/sse.js";
import { exit } from "process";

// Create a client instance
const client = new Client({
  name: "example-client",
  version: "1.0.0",
});

// Create a transport with the correct endpoint configuration
const transport = new SSEClientTransport(new URL("http://localhost:3000/sse"));
try {
  // Connect the client with the transport
  console.log("Connecting to MCP server...");
  await client.connect(transport);
  console.log("Connected successfully!");

  // Call the weather tool with the correct parameter structure
  console.log("Fetching weather for Bangkok...");

  // The tool expects parameters in this exact format
  const result = await client.callTool({
    name: "fetch_weather",
    arguments: {
      city: "bangkok",
    },
  });

  console.log("Weather result:", result);
  client.close();
  console.log("Client closed successfully!");
} catch (error: unknown) {
  console.error("Connection error:", error);
  if (error instanceof Error) {
    console.error("Error message:", error.message);
  } else {
    console.error("An unknown error occurred");
  }

}
