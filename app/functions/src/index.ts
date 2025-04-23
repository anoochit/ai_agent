/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {GoogleGenAI} from "@google/genai";
import {onDocumentCreated} from "firebase-functions/firestore";
import * as logger from "firebase-functions/logger";
import {onRequest} from "firebase-functions/v2/https";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// Import the functions you need from the SDKs you need
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || "";

// initialize the GoogleGenAI client
const gemini = new GoogleGenAI({
  apiKey: GEMINI_API_KEY,
});

/*
  hello functions
  This function is triggered when the endpoint is called
  It logs the request and sends a response
*/
export const helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

/*
  gemini function
  This function is triggered when a document is written to the specified path
  It calls the Gemini API with the prompt from the document and updates
  the document with the generated text
*/
const documentPath = "chats/{userId}/messages/{messageId}";
// This function is triggered when a document is created in the specified path
export const askGemini = onDocumentCreated(documentPath, (event) => {
  logger.info("Gemini document written!", {structuredData: true});
  const document = event.data;
  const prompt = document?.data()["prompt"];

  // no prompt found
  if (!prompt) {
    logger.error("No prompt found in the document");
    return null;
  }

  logger.info("Prompt:", {prompt}, {structuredData: true});

  // Call the Gemini API with prompt
  gemini.models
    .generateContent({
      model: "gemini-2.0-flash",
      contents: prompt,
      config: {
        candidateCount: 1,
      },
    })
    .then((response) => {
      logger.info(
        "Gemini response:",
        {response: JSON.stringify(response)},
        {structuredData: true}
      );

      // Check if the response is valid
      const candidate = response.candidates?.[0];

      if (!candidate) {
        logger.error("No candidates found in the response");
        // update the Firestore document with status false
        document.ref.set(
          {
            status: false,
            error: "No candidates found in the response",
          },
          {merge: true}
        );
      }
      // Check if the candidate has content
      const generatedText = candidate?.content?.parts?.[0].text;
      // Get usage data
      const totalTokenCount = response.usageMetadata?.totalTokenCount;
      if (!generatedText) {
        logger.error("No generated text found in the response");
        // Update the Firestore document with status false
        document.ref.set(
          {
            status: false,
            error: "No generated text found in the response",
          },
          {merge: true}
        );
      }
      // Log the generated text
      logger.info(
        "Generated text:",
        {generatedText},
        {structuredData: true}
      );
      // Update the Firestore document with the generated text
      return document.ref.set(
        {
          response: generatedText,
          totalTokenCount: totalTokenCount,
          status: true,
        },
        {merge: true}
      );
    })
    .catch((error) => {
      // Log for call Gemini API error
      logger.error("Error calling Gemini API:", {error});
      return document.ref.set(
        {
          error: error,
          status: false,
        },
        {merge: true}
      );
    });

  return null;
});
