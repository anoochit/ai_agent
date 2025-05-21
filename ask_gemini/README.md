# Ask Gemini

Ask Gemini is a Flutter chat application that leverages the power of Google's Gemini API to provide intelligent and conversational responses. Users can log in, engage in a chat interface, and receive AI-generated answers to their queries.

## Features

- **User Authentication:** Secure login functionality for users.
- **Real-time Chat Interface:** Intuitive chat UI for seamless conversation.
- **Gemini-Powered Responses:** Integrates with Google's Gemini API to provide intelligent, AI-generated answers.

## Project Structure

The project is organized into two main parts:

- **Flutter Application (`lib` directory):** This directory contains all the Dart code for the Flutter mobile application. It handles the user interface (UI), application state management, and communication with Firebase services.
- **Firebase Functions (`functions` directory):** This directory contains the Node.js code for the backend logic. These serverless functions are responsible for interacting with the Google Gemini API, processing requests from the app, and sending back responses.

## Backend

The backend logic for Ask Gemini is powered by Firebase Functions, a serverless compute service.

- **Firebase Functions:** These JavaScript/TypeScript functions run in a managed Node.js environment. They handle tasks that require server-side processing, such as authenticating users (handled by Firebase Authentication) and interacting with external APIs.

- **`askGemini` Function:**
    - **Purpose:** This is the core function responsible for getting responses from the Gemini API.
    - **Trigger:** It's triggered automatically when a new message document is created in the Firestore database (specifically at the path `chats/{userId}/messages/{messageId}`).
    - **Action:** When triggered, the function takes the `prompt` field from the new message, sends it to the Google Gemini API (using the `gemini-2.0-flash` model), and then updates the message document in Firestore with the AI-generated `response`, `totalTokenCount`, and a `status` field.
    - **Error Handling:** The function includes logic to log errors and update the Firestore document with an error status if the API call fails or the response is invalid.

## Getting Started

To get a local copy up and running, follow these steps.

### Prerequisites

Make sure you have the following installed:

- **Flutter SDK:** [Installation Guide](https://docs.flutter.dev/get-started/install)
- **Firebase CLI:** [Installation Guide](https://firebase.google.com/docs/cli#setup_update_cli)
- **Node.js:** (Required for Firebase Functions development) [Download Page](https://nodejs.org/) (LTS version recommended)

### Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/ask_gemini.git
    cd ask_gemini
    ```
    *(Replace `https://github.com/your-username/ask_gemini.git` with the actual repository URL if different)*

2.  **Configure Firebase:**
    - Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project (or use an existing one).
    - Add a Flutter application to your Firebase project. Follow the on-screen instructions to download the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) configuration files.
    - Place `google-services.json` into the `ask_gemini/android/app/` directory.
    - Place `GoogleService-Info.plist` into the `ask_gemini/ios/Runner/` directory (you might need to create the `ios` directory and configure iOS part of project if it's not already set up).
    - Enable **Authentication** (e.g., Email/Password) and **Firestore** in the Firebase console.

3.  **Set up Firebase Functions:**
    - Navigate to the `functions` directory:
      ```bash
      cd functions
      ```
    - Install dependencies:
      ```bash
      npm install
      ```
    - **Set up Gemini API Key:**
        - Obtain an API key from [Google AI Studio](https://aistudio.google.com/app/apikey).
        - Set the API key as an environment variable for your Firebase Functions. You can do this by running the following command (replace `YOUR_API_KEY` with your actual key):
          ```bash
          firebase functions:config:set gemini.key="YOUR_API_KEY"
          ```
        - *(Note: For local emulation, you might need to set this in a `.env` file or directly in your `functions/src/index.ts` for testing, but do not commit your API key to version control.)*

4.  **Run the Flutter App:**
    - Navigate back to the project root directory:
      ```bash
      cd ..
      ```
    - Get Flutter packages:
      ```bash
      flutter pub get
      ```
    - Run the app:
      ```bash
      flutter run
      ```

5.  **Deploy Firebase Functions:**
    - From the `functions` directory, deploy your functions:
      ```bash
      firebase deploy --only functions
      ```
    - *(Alternatively, from the project root directory: `firebase deploy --only functions`)*

## Usage

Once the application is running and Firebase is set up:

1.  **Launch the App:** Open the Ask Gemini application on your device or emulator.
2.  **Log In:** If it's your first time, you might need to create an account or log in using the configured authentication methods.
3.  **Start Chatting:** Navigate to the chat screen.
4.  **Ask Questions:** Type your questions or prompts into the message input field and send them.
5.  **Receive Responses:** The app will send your prompt to the backend, which then queries the Gemini API. The AI-generated response will appear in the chat.
