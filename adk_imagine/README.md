# AI Image Generation Agent with Prompt Refinement

This project implements an AI agent that takes a user's simple prompt, refines it into a detailed description, and then generates an image using Stability AI.

## Features

-   **Prompt Refinement**: Enhances simple user prompts with artistic details, lighting, composition, etc.
-   **Image Generation**: Uses Stability AI to generate images from detailed prompts.
-   **Sequential Agent Workflow**: Orchestrates prompt refinement and image generation steps.
-   **FastAPI Server**: Exposes the agent via an API and serves generated images.

## Architecture

The system consists of a root agent (`root_agent` in `query_agent/agent.py`) that manages a sequence of sub-agents:

1.  **`imagine_agent`** (`imagine_agent/agent.py`):
    *   Receives the initial user prompt.
    *   Uses a Gemini model to transform the simple prompt into a highly detailed prompt suitable for image generation.
    *   Outputs `detailed_prompt`.

2.  **`painter_agent`** (`painter_agent/agent.py`):
    *   Receives the `detailed_prompt` from `imagine_agent`.
    *   Uses the `painter_tool` which calls the Stability AI API to generate an image.
    *   Saves the image to the `./generated` folder.
    *   Returns the path to the generated image.

The `root_agent` is exposed via a FastAPI application defined in `main.py`.

## Prerequisites

-   Python 3.x
-   `uv` (or `pip`) for package management and running the application.
-   A Stability AI API Key.

## Setup

1.  **Clone the repository (if applicable).**

2.  **Install dependencies:**
    This project uses `uv`. Ensure your dependencies (likely managed in a `pyproject.toml` or `requirements.txt` if you have one) are installed in your `uv` environment.

3.  **Set Environment Variables:**
    You **must** set your Stability AI API key as an environment variable. The `painter_agent` relies on this key.
    ```bash
    export STABILITY_AI_API_KEY="your_stability_ai_api_key_here"
    ```
    On Windows (Command Prompt):
    ```bash
    set STABILITY_AI_API_KEY="your_stability_ai_api_key_here"
    ```
    Or Windows (PowerShell):
    ```powershell
    $env:STABILITY_AI_API_KEY="your_stability_ai_api_key_here"
    ```
    For persistent storage of environment variables, consider using a `.env` file with a library like `python-dotenv`, especially for local development.

## Running the Server

You can run the FastAPI server using Uvicorn. The server will run on `http://localhost:8080` by default (or the port specified by the `PORT` environment variable, as configured in `main.py` when run as a script).

1.  **Using Uvicorn directly (recommended for consistency):**
    Navigate to the `adk_imagine` directory (where `main.py` is located).
    ```bash
    uvicorn main:app --host 0.0.0.0 --port 8080 --reload
    ```
    The `--reload` flag is useful for development as it automatically restarts the server on code changes. If you run `python main.py`, it will also default to port 8080.

2.  **Using ADK CLI (alternative):**
    The original README mentioned:
    ```bash
    uv run adk api_server
    ```
    This command's behavior (e.g., default port) depends on your ADK project configuration. The ADK CLI often defaults to port 8000. If you use this method and it runs on a different port, adjust the port in the `curl` examples below accordingly.

## Interacting with the Agent

Once the server is running (assuming on `http://127.0.0.1:8080` as per the Uvicorn command above):

1.  **Create a Session:**
    This step initializes a session for a user with the `query_agent` app.
    ```bash
    curl -X POST http://127.0.0.1:8080/apps/query_agent/users/u_123/sessions/s_123 \
    -H "Content-Type: application/json"
    ```
    You should receive a JSON response confirming session creation.

2.  **Send a Prompt to the Agent:**
    Send your image prompt to the `/run` endpoint. The `imagine_agent` will refine it, and then `painter_agent` will generate the image.
    ```bash
    curl -X POST http://127.0.0.1:8080/run \
    -H "Content-Type: application/json" \
    -d '{
    "app_name": "query_agent",
    "user_id": "u_123",
    "session_id": "s_123",
    "new_message": {
        "role": "user",
        "parts": [{
        "text": "a lizard walking on a dry branch tree in the desert on the dawn of the sun light"
        }]
    }
    }'
    ```

## Output

-   **API Response**: The API will return a JSON response. The final message from the agent (after `painter_agent` completes) will typically include a confirmation and the relative path to the generated image. The exact phrasing depends on the `painter_agent`'s LLM based on its instructions. For example:
    ```json
    {
        // ... other session data ...
        "messages": [
            // ... previous messages ...
            {
                "role": "model",
                "parts": [
                    {
                        "text": "Successfully generated image with Stability AI and saved it as 'generated/stability_image_xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.png'. You can view it at /generated/stability_image_xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.png"
                    }
                ]
            }
        ]
    }
    ```

-   **Image Files**: Generated images are saved in the `adk_imagine/generated/` folder within your project directory.

-   **Accessing Images via Web**: Since `main.py` mounts the `generated` folder as static files, you can access the images directly via your browser or any HTTP client:
    `http://127.0.0.1:8080/generated/<image_filename.png>`
    For example, if the agent reports the image is `generated/stability_image_123.png`, you can access it at `http://127.0.0.1:8080/generated/stability_image_123.png`.

## Development Notes

-   **CORS**: `main.py` currently sets `ALLOWED_ORIGINS = ["*"]`. For production environments, it's crucial to restrict this to your specific frontend domain(s) for security.
-   **Error Handling**: The `painter_agent` includes error handling for API key issues and Stability AI API errors. Check server logs for details if image generation fails.
-   **OpikTracer**: Tracing with `OpikTracer` is commented out in the agent files. If you intend to use Opik for tracing, you'll need to uncomment these lines and ensure Opik is correctly configured.

```bash
uv run adk api_server
```

or

```bash
uvicorn main:app --host 0.0.0.0
```

request session

```bash
curl -X POST http://127.0.0.1:8000/apps/query_agent/users/u_123/sessions/s_123 \
-H "Content-Type: application/json"
```

sent request to agent

```bash
curl -X POST http://127.0.0.1:8000/run \
-H "Content-Type: application/json" \
-d '{
"app_name": "query_agent",
"user_id": "u_123",
"session_id": "s_123",
"new_message": {
    "role": "user",
    "parts": [{
    "text": "a lizard walking on a dry branch tree  in the desert on the dawn of the sun light"
    }]
}
}'
```

image will save at  `generated` folder
