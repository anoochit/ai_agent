from google.adk.agents import Agent
import os
import uuid
import requests 

# --- Configuration --- 
# Ensure this environment variable is set before running the agent
STABILITY_AI_API_KEY = os.getenv("STABILITY_AI_API_KEY")

if not STABILITY_AI_API_KEY:
    print("Warning: STABILITY_AI_API_KEY environment variable not set. PainterTool will not function properly.")

# --- Constants ---
GENERATED_FOLDER = "generated"


def painter_tool(detailed_prompt: str) -> dict:
    """
    The core logic for generating the image.
    Input: detailed_prompt (str): The text description of the image to generate. (Synchronous)
    Returns: str: A message indicating success or failure, potentially with image details (e.g., URL or identifier).
    """
    # Clean the input prompt by removing leading/trailing whitespace and newlines
    cleaned_prompt = detailed_prompt.strip()

    print(
        f"PainterTool received cleaned_prompt: '{cleaned_prompt}' (Original: '{detailed_prompt}')")

    if not STABILITY_AI_API_KEY:
        return "Error: Stability AI API key is not configured. Cannot generate image."

    try:
        print(
            f"Generating image with Stability AI REST API for prompt: '{detailed_prompt}'...")
        api_host = "https://api.stability.ai"
        api_endpoint = f"{api_host}/v2beta/stable-image/generate/core"

        headers = {
            "authorization": f"Bearer {STABILITY_AI_API_KEY}",
            "accept": "image/*",  # Accept image formats
            # "accept": "application/json"
        }
        # Note: 'files' is used for multipart/form-data,
        # which is needed here even without explicit file upload
        files = {"none": ''}
        data = {
            "prompt": cleaned_prompt,  # Use the cleaned prompt
            "output_format": "png",  # Or "jpeg", "webp"
            # Add other parameters as needed,
            # e.g., aspect_ratio, negative_prompt, seed, style_preset
            # Example: Enforce square image
            # "aspect_ratio": "1:1",
            # Example: Use a style preset
            # "style_preset": "photorealistic",
        }

        # Make the synchronous requests.post call directly
        answers = requests.post(
            api_endpoint,
            headers=headers,
            files=files,
            data=data
        )

        if answers.status_code == 200:
            # Ensure the 'generated' folder exists
            if not os.path.exists(GENERATED_FOLDER):
                os.makedirs(GENERATED_FOLDER)

            file_name = f"stability_image_{uuid.uuid4()}.png"  # Base file name
            file_path = os.path.join(GENERATED_FOLDER, file_name)  # Full path
            with open(file_path, "wb") as f:
                f.write(answers.content)
            print(f"Stability AI image saved as '{file_path}'.")
            return {
                # 'result' : f"Successfully generated image with Stability AI and saved it as '{file_path}' based on the description: '{cleaned_prompt}'.",
                'result' : GENERATED_FOLDER + '/' + file_name
            }
            # return f"Successfully generated image with Stability AI and saved it as '{file_path}' based on the description: '{cleaned_prompt}'."
        else:
            # Attempt to parse JSON error, otherwise use text
            try:
                error_details = answers.json()
            except requests.exceptions.JSONDecodeError:
                error_details = answers.text
            print(
                f"Error from Stability AI API: {answers.status_code} - {error_details}")
            return {
                'result' : f"Image generation failed for '{cleaned_prompt}'. Status: {answers.status_code}, Details: {error_details}"
            }
            # return f"Image generation failed for '{cleaned_prompt}'. Status: {answers.status_code}, Details: {error_details}"

    except Exception as e:
        print(f"Error during Stability AI image generation: {e}")
        return {
            'result' : "An error occurred while trying to generate the image with Stability AI for '{cleaned_prompt}'. Error: {e}"
        }
        
        # return f"An error occurred while trying to generate the image with Stability AI for '{cleaned_prompt}'. Error: {e}"

painter_agent = Agent(
    name="painter_agent",
    model="gemini-2.0-flash",
    description="An agent that generates images based on text descriptions using Stability AI.",
    instruction="You are a helpful image generation assistant. Use the painter_tool to create an image based on the user's description. Provide the user with confirmation and the filename of the saved image upon success.",
    tools=[painter_tool]
)
