# ask_n8n: Chat with your RAG Agent via n8n

`ask_n8n` is a Flutter application that provides a mobile chat interface to interact with a Retrieval Augmented Generation (RAG) agent. This agent is expected to be accessible via an n8n webhook.

## Features

*   **Chat Interface:** Send messages to and receive responses from a RAG agent.
*   **Markdown Rendering:** Displays agent responses in markdown format for rich text.
*   **Session Management:** Maintains a unique session ID for contextual conversations.
*   **n8n Integration:** Communicates with an n8n webhook (default: `http://localhost:5678/webhook/rag`) which should be connected to your RAG pipeline.

## Prerequisites

Before running this application, ensure you have:

1.  **Flutter SDK** installed.
2.  An **n8n instance** running.
3.  An **n8n webhook workflow** configured to:
    *   Listen at `http://localhost:5678/webhook/rag` (or update the URI in `lib/services/rag_agent.dart` if your endpoint differs).
    *   Accept a POST request with a JSON body containing `{"chatInput": "your message", "sessionId": "session_id"}`.
    *   Connect to your RAG agent/pipeline.
    *   Return a JSON response. The application currently expects the agent's output in the first element of a list, under an "output" key (e.g., `[{"output": "agent_response_text"}]`).

