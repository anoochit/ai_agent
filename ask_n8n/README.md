# ask_n8n: Your Mobile Chat Interface for n8n-powered RAG Agents

`ask_n8n` is a Flutter-based mobile application designed to provide a seamless and interactive chat experience with a Retrieval Augmented Generation (RAG) agent. The core idea is to enable users to easily "ask" questions or give instructions to a powerful AI model whose responses are grounded in a specific set of documents or data, all orchestrated through n8n workflows.

## What is Retrieval Augmented Generation (RAG)?

Retrieval Augmented Generation (RAG) is a technique that enhances the capabilities of large language models (LLMs) by connecting them to external knowledge sources. In a typical RAG setup:

1.  **Retrieval:** When a user provides a query, the system first searches a knowledge base (e.g., a collection of documents, a database) for information relevant to the query.
2.  **Augmentation:** The retrieved information is then combined with the original query and passed as context to the LLM.
3.  **Generation:** The LLM uses this augmented prompt (query + retrieved context) to generate a more informed, accurate, and contextually relevant response.

RAG helps reduce LLM hallucinations (fabricating facts) and enables them to provide answers based on specific, up-to-date, or proprietary information.

## How `ask_n8n` Leverages RAG

In the context of `ask_n8n`:

*   You, the user, interact with the **`ask_n8n` mobile app**, sending your questions or messages.
*   The app forwards your message, along with a unique session ID, to an **n8n webhook**.
*   This n8n webhook triggers a workflow that you design. This workflow is responsible for:
    *   Taking your input.
    *   Performing the **retrieval** step of RAG (e.g., querying a vector database like Weaviate, Pinecone, or a local document store).
    *   Passing your input and the retrieved context to your chosen **LLM** (e.g., OpenAI's GPT models, a local LLM).
    *   Receiving the generated response from the LLM.
    *   Sending this response back to the `ask_n8n` app.
*   The app then displays the RAG agent's response to you.

This setup allows for flexible and customizable RAG pipelines, where n8n acts as the central orchestrator connecting your mobile interface, your data sources, and your language models.

## Features

*   **Intuitive Chat Interface:**
    *   Allows users to interact with the RAG agent in a familiar messaging format.
    *   Benefit: Simplifies communication, making it easy to send queries and receive AI-generated, document-grounded responses without a steep learning curve.

*   **Rich Markdown Rendering:**
    *   Displays responses from the RAG agent in markdown format.
    *   Benefit: Enables clear and well-formatted text, including headings, lists, bold/italic text, and links, making complex information easier to read and understand.

*   **Persistent Session Management:**
    *   Maintains a unique session ID for each conversation. This ID is sent with every request to the n8n webhook.
    *   Benefit: Allows the RAG agent (and your n8n workflow) to remember the context of the ongoing conversation, enabling follow-up questions and more coherent, human-like interactions.

*   **Seamless n8n Integration:**
    *   Designed to connect directly to an n8n webhook, which acts as the backend orchestrator for your RAG pipeline.
    *   Benefit: Offers immense flexibility to users who can design and customize their RAG workflows visually in n8n. This includes choosing different data sources for retrieval, selecting various LLMs for generation, and adding custom logic, all without modifying the app itself. The app simply acts as a user-friendly front-end to your powerful n8n automation.

## Getting Started

This section will guide you through setting up and running the `ask_n8n` application.

### 1. Prerequisites

Before you begin, ensure you have the following set up:

*   **Flutter SDK:** You'll need the Flutter SDK installed on your development machine. If you don't have it, follow the official Flutter installation guide: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
*   **n8n Instance:** A running instance of n8n is required. This can be a local installation, a Docker container, or a cloud-hosted n8n instance.
*   **n8n RAG Webhook Workflow:** You need an n8n webhook workflow configured to:
    *   Listen for POST requests (e.g., at the default `http://localhost:5678/webhook/rag`).
    *   Accept a JSON body with `{"chatInput": "your message", "sessionId": "session_id"}`.
    *   Connect to your RAG agent/pipeline (this is the part you build in n8n to fetch data and call your LLM).
    *   Return a JSON response. The application expects the agent's output in the first element of a list, under an "output" key (e.g., `[{"output": "agent_response_text"}]`).

### 2. Clone the Repository

Get the `ask_n8n` source code by cloning the repository. Open your terminal and run:

```bash
git clone <repository_url> # Replace <repository_url> with the actual URL of this repository
cd ask_n8n
```
*If you've downloaded the source as a ZIP file, extract it and navigate into the project directory.*

### 3. Install Dependencies

Navigate to the project directory in your terminal (if you aren't already there) and install the required Flutter packages:

```bash
flutter pub get
```

### 4. Configure n8n Webhook URL

The application needs to know where your n8n RAG workflow is listening. The default URL is `http://localhost:5678/webhook/rag`.

*   If your n8n webhook is accessible via a different URL (e.g., if n8n is running on a different machine, in the cloud, or you've customized the path), you **must** update it in the application.
*   Open the file: `lib/services/rag_agent.dart`
*   Locate the `_webhookUrl` variable (it's a `static const String`).
*   Change its value to your specific n8n webhook endpoint. For example:
    ```dart
    // In lib/services/rag_agent.dart
    // Update this line with your actual n8n webhook URL:
    // static const String _webhookUrl = 'YOUR_N8N_WEBHOOK_URL_HERE'; 
    static const String _webhookUrl = 'http://localhost:5678/webhook/rag'; // Default
    ```
    *Ensure the URL is correct, otherwise the app won't be able to communicate with your RAG agent.*

### 5. Run the Application

Once the prerequisites are met, dependencies are installed, and the webhook URL is correctly configured:

1.  Ensure you have an Android/iOS emulator running or a physical device connected to your computer and recognized by Flutter (`flutter devices` command can check this).
2.  Open your terminal in the `ask_n8n` project directory.
3.  Run the application using:

    ```bash
    flutter run
    ```

This command will build the Flutter application and install it on your selected device/emulator. The app should then launch, and you can start sending messages to your n8n-powered RAG agent. If you encounter any issues, review the Flutter console output for error messages.

## Usage

Once you have successfully set up the project and have it running (as described in the "Getting Started" section), you can begin interacting with your RAG agent through the `ask_n8n` app.

### Interacting with the Agent

The application provides a straightforward chat interface:

1.  **Chat Display Area:** This is the main part of the screen where your messages and the agent's responses will appear. Your messages are typically aligned to the right, and the agent's responses to the left.
2.  **Message Input Field:** At the bottom of the screen, you'll find a text field labeled something like "Type your message...". Tap on this field to bring up the keyboard and type your question or prompt for the RAG agent.
3.  **Send Button:** Next to the input field, there's a send button (often an icon, like a paper airplane). After typing your message, tap this button to send it to the n8n RAG agent.

### Workflow

The basic interaction flow is as follows:

1.  **Type your message:** Enter your query or instruction into the message input field.
2.  **Send the message:** Tap the send button.
3.  **Wait for response:** The app will display a loading indicator or similar feedback while it communicates with your n8n webhook. Your n8n workflow will process the request (perform retrieval, call the LLM, etc.) and send back a response.
4.  **View response:** The agent's response will appear in the chat display area. Thanks to markdown rendering, this can include formatted text, lists, etc., making it easy to read.

### Example Interaction

Here's a simple example of what an interaction might look like:

**You:**
> What is Retrieval Augmented Generation?

**(App sends this to n8n, n8n processes it with your RAG pipeline)**

**Agent (displayed in app):**
> Retrieval Augmented Generation (RAG) is a technique that enhances Large Language Model (LLM) responses by grounding them in external knowledge sources. It involves retrieving relevant information from a dataset and providing it as context to the LLM along with the user's query.

Remember, the quality and content of the agent's responses depend entirely on how you've configured your RAG pipeline and the LLM within your n8n workflow.

## Troubleshooting

Encountering issues? Here are some common problems and how to resolve them:

### 1. App Can't Connect to n8n Webhook

If the app shows errors like "Connection refused," "Timeout," or similar network-related issues when sending a message:

*   **Verify Webhook URL:**
    *   Double-check the `_webhookUrl` in `lib/services/rag_agent.dart`. Ensure it exactly matches your n8n webhook URL, including `http/https`, hostname, port, and path.
    *   If using `localhost` for n8n on your computer and running the app on an Android emulator, `localhost` in the app will point to the emulator itself, not your computer. Use your computer's actual network IP address instead (e.g., `http://192.168.1.10:5678/webhook/rag`). Physical iOS devices require your computer's network IP.
*   **n8n Instance Running:** Confirm that your n8n instance is running.
*   **n8n Workflow Active:**
    *   Ensure your n8n workflow containing the webhook node is **active**.
    *   Make sure the workflow is **saved** after any changes.
*   **Test Webhook Independently:** Use a tool like `curl` or Postman to send a test POST request to your n8n webhook URL with the expected JSON body: `{"chatInput": "test", "sessionId": "test_session"}`. This helps isolate whether the issue is with the app or the n8n setup.
    ```bash
    curl -X POST -H "Content-Type: application/json" -d '{"chatInput": "hello", "sessionId": "curl_test"}' http://localhost:5678/webhook/rag 
    ```
    (Adjust URL as needed)
*   **Network Connectivity & Firewalls:**
    *   If n8n is on a different machine or server, ensure there's network connectivity between the device/emulator running the app and the n8n server.
    *   Check for firewalls on the machine running n8n that might be blocking incoming connections on the webhook port.

### 2. No Response or Incorrect Response from Agent

If messages are sent but the agent doesn't respond, or the response is an error or not what you expect:

*   **Check n8n Workflow Executions:**
    *   Open your n8n instance and look at the "Executions" list. Find the execution triggered by your app's message.
    *   Inspect the execution for any errors in the nodes. This is the most common place to find issues with your RAG pipeline logic.
*   **Verify RAG Pipeline Configuration:**
    *   Carefully review the configuration of each node in your n8n RAG workflow (data retrieval, LLM prompt construction, LLM call, response parsing).
*   **LLM Accessibility & Configuration:**
    *   Ensure the LLM service (e.g., OpenAI, local LLM) is accessible from your n8n instance.
    *   Check API keys, model names, and other parameters in your LLM node.
*   **Expected JSON Format:**
    *   The `ask_n8n` app expects the n8n webhook to return a JSON response where the agent's output is in the first element of a list, under an "output" key (e.g., `[{"output": "agent_response_text"}]`). Ensure your n8n workflow ends with a node that formats the response correctly.

### 3. Flutter Build or Run Issues

If you're having trouble building or running the Flutter app itself:

*   **Flutter Environment:**
    *   Ensure your Flutter SDK is correctly installed and its `bin` directory is in your system's PATH.
    *   Run `flutter doctor` in your terminal. This command checks your Flutter installation and reports any issues or missing dependencies (like Android SDK, Xcode for iOS, Chrome for web). Address any reported problems.
*   **Install Dependencies:** If you haven't already, or if you encounter errors related to missing packages, run:
    ```bash
    flutter pub get
    ```
*   **Device/Emulator Connectivity:**
    *   Ensure you have an Android emulator running, or a physical Android/iOS device connected and properly configured for development.
    *   Run `flutter devices` to see a list of connected devices that Flutter can recognize. If your device isn't listed, you'll need to troubleshoot its connection.
*   **Review Flutter Console Output:** Pay close attention to any error messages printed in the console when you run `flutter run`. These messages often provide specific clues about what's wrong.

If you continue to face issues, consider searching online for the specific error messages you encounter, as the Flutter and n8n communities are very active.

## Contributing

Contributions are welcome and appreciated! Whether you're fixing a bug, proposing a new feature, or improving documentation, your help is valuable.

### Reporting Bugs and Suggesting Features

*   **Bugs:** If you find a bug, please check the existing issues on the project's repository (if applicable, e.g., on GitHub) to see if it has already been reported. If not, please open a new issue, providing a clear description of the bug, steps to reproduce it, and your environment (Flutter version, device OS, etc.).
*   **Feature Requests:** If you have an idea for a new feature or an enhancement to an existing one, feel free to open an issue to discuss it. Describe the feature, its potential benefits, and any ideas you have on its implementation.

### Pull Requests

If you'd like to contribute code, please follow these general steps:

1.  **Fork the Repository:** Create your own fork of the main project repository.
2.  **Create a Branch:** For any new feature or bug fix, create a new branch in your fork. Choose a descriptive branch name (e.g., `fix/login-button-bug` or `feature/user-profiles`).
3.  **Make Changes:** Implement your changes, adhering to the existing code style as much as possible.
4.  **Test Your Changes:** Ensure your changes don't break existing functionality and test any new functionality thoroughly. (If there are automated tests, please ensure they pass, or add new ones if appropriate).
5.  **Commit Your Changes:** Write clear, concise commit messages explaining the purpose of your changes.
6.  **Submit a Pull Request (PR):** Push your branch to your fork and then open a pull request to the main project repository. Provide a clear description of the changes in your PR, why they were made, and reference any relevant issue numbers.

### Coding Style and Tests

*   Try to follow the existing coding style and conventions used in the project.
*   For significant changes, consider whether unit tests or widget tests are appropriate to ensure robustness and prevent regressions.

Thank you for considering contributing to `ask_n8n`!

## License

License information for this project is currently not specified.

It is recommended to add a license file (e.g., `LICENSE.md`) to the project root. Consider using a standard open-source license such as the [MIT License](https://opensource.org/licenses/MIT) or the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) if the project is intended to be open source.

For now, please assume all rights are reserved by the project maintainers unless a license is explicitly stated.

