# Ask Imagine

A Flutter application that generates images from text prompts using an imagine agent.

## Features

- Text input for image generation prompts.
- Displays the generated image.

## How to Run

1. Ensure the imagine agent backend service is running.
2. Update the `agentUri` in `lib/services/imagine_agent.dart` if the backend is not on `http://10.0.2.2:8000`.
3. Run the Flutter application using `flutter run`.
