import { FunctionDeclaration, GoogleGenAI, Type } from "@google/genai";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { SSEClientTransport } from "@modelcontextprotocol/sdk/client/sse.js";
import dotenv from "dotenv";
import readline from "readline/promises";

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const MCP_SERVER_ENDPOINT = process.env.MCP_SERVER_ENDPOINT || 'http://localhost:3000/sse';

dotenv.config();

class MCPClient {
  private mcp: Client;
  private gemini: GoogleGenAI;
  private transport: SSEClientTransport | null = null;
  tools: any;

  // connect to MCP Server SSE
  constructor() {
    this.gemini = new GoogleGenAI({
      apiKey: GEMINI_API_KEY,
    });
    this.mcp = new Client({ name: "mcp-client-cli", version: "1.0.0" });
  }

  // Connect to MCP Server SSE
  async connectToServer(serverURL: string) {
    this.transport = new SSEClientTransport(new URL(serverURL));
    await this.mcp.connect(this.transport);
    const toolsResult = await this.mcp.listTools();

    this.tools = toolsResult.tools.map((tool) => {
      const parameters = tool.inputSchema ?? {
        type: "object",
        properties: {},
      };

      return {
        name: tool.name,
        description: tool.description || "",
        parameters: parameters,
      };
    });
    console.log(
      "Connected to server with tools:",
      JSON.stringify(this.tools, null, 2)
    );
  }

  // Execute a function call on the MCP server
  async executeFunction(functionName: any, args: any) {
    try {
      console.log(`Invoking MCP tool: ${functionName} with args:`, args);
      const result = await this.mcp.callTool({
        name: functionName,
        arguments: args,
      });
      console.log(`Tool execution result:`, result);
      return result;
    } catch (error) {
      console.error(`Error executing tool ${functionName}:`, error);
      throw error;
    }
  }

  // Process query with LLM aka Gemini
  async processQuery(query: string) {
    if (this.tools.length === 0) {
      console.warn("No tools available to process the query with.");
    }

    try {
      // Convert MCP tools to Gemini function declarations format
      const functionDeclarations = this.tools.map((tool: any) => {
        // Create a deep copy of the parameters object
        const parameters = JSON.parse(JSON.stringify(tool.parameters));

        // Remove fields that aren't compatible with Gemini
        if (parameters.$schema) delete parameters.$schema;
        if (parameters.additionalProperties !== undefined)
          delete parameters.additionalProperties;

        return {
          name: tool.name,
          description: tool.description,
          parameters: parameters,
        } as FunctionDeclaration;
      });

      // call Gemini model
      const model = this.gemini.models;
      const result = await model.generateContent({
        model: "gemini-2.5-pro-exp-03-25",
        contents: [{ role: "user", parts: [{ text: query }] }],
        config: {
          tools: [
            {
              functionDeclarations: functionDeclarations,
              // Sample for function declarations
              //[
              // {
              //   name: "fetch_weather",
              //   description: "Get weather forecast for a city",
              //   parameters: {
              //     type: Type.OBJECT,
              //     properties: {
              //       city: {
              //         type: Type.STRING,
              //         description: "City name",
              //       },
              //     },
              //     required: ["city"],
              //   },
              // },
              // ],
            },
          ],
        },
      });

      // It's usually better to work with the response object
      const response = result;
      console.log("Gemini Response:", JSON.stringify(response, null, 2));

      // Handle Function Calls
      const functionCalls = response?.functionCalls;
      if (functionCalls && functionCalls.length > 0) {
        console.log(
          "Function call requested:",
          JSON.stringify(functionCalls, null, 2)
        );

        // For each function call requested by Gemini
        const functionResults = [];
        for (const functionCall of functionCalls) {
          const { name, args } = functionCall;

          try {
            // Execute the function via MCP client
            const result = await this.executeFunction(name!, args);
            functionResults.push({
              name,
              args,
              result,
            });
          } catch (toolError) {
            console.error(`Error executing tool ${name}:`, toolError);
            functionResults.push({
              name,
              args,
              error: `Error executing tool ${name}: ${toolError}`,
            });
          }
        }

        // Optional: Send function results back to Gemini for a follow-up response
        if (functionResults.length > 0) {
          const followUpResponse = await this.sendFunctionResultsToGemini(
            query,
            functionResults
          );
          return followUpResponse;
        }
      } else {
        // Handle regular text response
        const textResponse = response.text;
        console.log("Text Response:", textResponse);
        return textResponse;
      }
    } catch (error) {
      // Log the specific error for better debugging
      console.error("Error processing query with Gemini:", error);
    }
  }

  // Send function results back to Gemini for follow-up response
  async sendFunctionResultsToGemini(
    originalQuery: string,
    functionResults: any[]
  ) {
    try {
      const model = this.gemini.models;

      // Prepare the conversation history
      const contents = [
        { role: "user", parts: [{ text: originalQuery }] },
        {
          role: "model",
          parts: [{ text: "Summary of function results" }],
          functionCalls: functionResults.map((fr) => ({
            result: fr.result,
          })),
        },
      ];

      const result = await model.generateContent({
        model: "gemini-2.5-pro-exp-03-25",
        contents: contents,
      });

      const textResponse = result.text;
      console.log("Follow-up Response:", textResponse);
      return textResponse;
    } catch (error) {
      console.error("Error sending function results to Gemini:", error);
      throw error;
    }
  }

  // Close MCP server connection
  async cleanup() {
    await this.mcp.close();
  }

  // Chat loop
  async chatLoop() {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    try {
      console.log("\nMCP Client Started!");
      console.log("Type your queries or 'quit' to exit.");

      while (true) {
        const message = await rl.question("\nQuery: ");
        if (message.toLowerCase() === "quit") {
          break;
        }
        const response = await this.processQuery(message);
        console.log("\n" + response);
      }
    } finally {
      rl.close();
    }
  }
}

// main
async function main() {
  const mcpClient = new MCPClient();
  try {
    await mcpClient.connectToServer(MCP_SERVER_ENDPOINT);
    // await mcpClient.processQuery("What's weather in Bangkok");
    // await mcpClient.processQuery("My weight is 70kg 1.65m. What's my BMI?");
    await mcpClient.chatLoop();
  } finally {
    await mcpClient.cleanup();
    process.exit(0);
  }
}

main();
