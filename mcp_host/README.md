# MCP Host

## Overview
The MCP Host is a client-server application that connects to an MCP (Model Context Protocol) server and integrates with Google Gemini AI for advanced query processing and tool execution.

## Features
- Connects to an MCP server using SSE (Server-Sent Events).
- Executes tools provided by the MCP server.
- Processes user queries with Google Gemini AI.
- Supports chat-based interaction with a loop for continuous queries.

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd mcp_host
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up environment variables in a `.env` file:
   ```env
   GEMINI_API_KEY=<your-gemini-api-key>
   MCP_SERVER_ENDPOINT=<mcp-server-endpoint>
   ```

## Usage

1. Start the MCP Host:
   ```bash
   npm start
   ```

2. Example query:
   ```
   My weight is 70kg 1.65m. What's my BMI?
   ```

## Code Structure

- `src/index.ts`: Main entry point of the application.
- `MCPClient` class:
  - Connects to the MCP server.
  - Processes queries using Google Gemini AI.
  - Executes tools and handles function calls.

## License
This project is licensed under the MIT License. See the LICENSE file for details.