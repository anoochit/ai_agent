/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable require-jsdoc */
/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {onCall, onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {Client} from "@modelcontextprotocol/sdk/client/index.js";
import {FunctionDeclaration, GoogleGenAI} from "@google/genai";
import {SSEClientTransport} from "@modelcontextprotocol/sdk/client/sse.js";

interface MCPTool {
  name: string;
  description: string;
  parameters: any;
}

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const MCP_SEVER_URL = "http://127.0.0.1:3000/sse";

const gemini = new GoogleGenAI({
  apiKey: GEMINI_API_KEY,
});

const mcp = new Client({name: "mcp-client-cli", version: "1.0.0"});

export const helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

export const askGemini = onCall((request) => {
  const question = request.data.question;

  // connect to mcp server get toollist
  connectToMCPServer();
  const result = processQuery(question);

  return result;
});

let tools: MCPTool[] = [];
let transport;

async function connectToMCPServer() {
  transport = new SSEClientTransport(new URL(MCP_SEVER_URL));
  await mcp.connect(transport);
  const toolsResult = await mcp.listTools();

  tools = toolsResult.tools.map((tool) => {
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
  logger.info(
    "Connected to server with tools:",
    JSON.stringify(tools, null, 2)
  );
}
async function processQuery(question: string) {
  if (tools.length == 0) {
    console.warn("No tools available to process the query with.");
    return "No tools available to process the query with.";
  }

  try {
    // Convert MCP tools to Gemini function declarations format
    const functionDeclarations = tools.map((tool) => {
      // Create a deep copy of the parameters object
      const parameters = JSON.parse(JSON.stringify(tool.parameters));

      // Remove fields that aren't compatible with Gemini
      if (parameters.$schema) delete parameters.$schema;
      if (parameters.additionalProperties !== undefined) {
        delete parameters.additionalProperties;
      }

      return {
        name: tool.name,
        description: tool.description,
        parameters: parameters,
      } as FunctionDeclaration;
    });

    // check function declarations
    logger.info("functionDeclarations:", functionDeclarations, {
      structuredData: true,
    });

    // call Gemini model
    const model = gemini.models;
    const response = await model.generateContent({
      model: "gemini-2.0-flash",
      contents: [{role: "user", parts: [{text: question}]}],
      config: {
        tools: [
          {
            functionDeclarations: functionDeclarations,
          },
        ],
      },
    });

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
        const {name, args} = functionCall;

        // Add this check: Ensure 'name' is defined before proceeding
        if (!name) {
          logger.error(
            "Received a function call without a name:",
            functionCall
          );
          // Decide how to handle this - skip, add an error result, etc.
          // Example: Add an error entry to functionResults
          functionResults.push({
            name: undefined, // Or a placeholder like 'unknown'
            args,
            error: "Function call received without a name.",
          });
          continue; // Skip to the next function call
        }

        try {
          // Execute the function via MCP client
          const result = await executeFunction(name, args);

          functionResults.push({
            name,
            args,
            result,
          });
        } catch (toolError) {
          logger.error(`Error executing tool ${name}:`, toolError);
          functionResults.push({
            name,
            args,
            error: `Error executing tool ${name}: ${toolError}`,
          });
        }
      }

      // Optional: Send function results back to Gemini for a follow-up response
      if (functionResults.length > 0) {
        const followUpResponse = await sendFunctionResultsToGemini(
          question,
          functionResults
        );
        return followUpResponse;
      } else {
        // Handle case where function calls were requested, but none succeeded
        // or produced results to send back.
        logger.warn("Function calls requested, but no results obtained.");
        return null;
      }
    } else {
      // Handle regular text response
      const textResponse = response.text;
      console.log("Text Response:", textResponse);
      return textResponse;
    }
  } catch (e) {
    logger.error(e);
    return null;
  }
}

// Execute a function call on the MCP server
async function executeFunction(functionName: string, args: any ) {
  try {
    logger.info(`Invoking MCP tool: ${functionName} with args:`, args);
    const result = await mcp.callTool({
      name: functionName,
      arguments: args,
    });
    logger.info("Tool execution result:", result);
    return result;
  } catch (error) {
    logger.error(`Error executing tool ${functionName}:`, error);
    throw error;
  }
}


// Send function results back to Gemini for follow-up response
async function sendFunctionResultsToGemini(
  originalQuery: string,
  functionResults: any[]
) {
  try {
    const model = gemini.models;

    const mcpResult = functionResults.map((fr) => (
      fr.result.content[0].text + "\n"
    ));

    console.log(JSON.stringify(mcpResult, null, 2));

    // Prepare the conversation history
    const contents = [
      {
        role: "user",
        parts: [{text: "Summary\n"}, {text: `${mcpResult}`}],
      },
    ];

    const result = await model.generateContent({
      model: "gemini-2.0-flash",
      contents: contents,
    });

    const textResponse = result.text;
    console.log("Summary Response:", textResponse);
    return textResponse;
  } catch (error) {
    console.error("Error sending function results to Gemini:", error);
    throw error;
  }
}
