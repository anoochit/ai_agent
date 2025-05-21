# Ask Agent MCP

## Description

Ask Agent MCP is a Flutter application that allows users to ask questions to a Gemini AI model. It uses Firebase for backend services, including Cloud Functions to communicate with the Gemini API.

## Getting Started

### Prerequisites

*   Flutter SDK installed.
*   A Firebase project created and configured.
*   Firebase CLI installed.
*   (If applicable) Access to Gemini API or a Firebase extension for Gemini configured.

### Installation & Setup

1.  Clone the repository.
2.  Navigate to the `ask_agent_mcp` directory.
3.  Run `flutter pub get` to install Flutter dependencies.
4.  Navigate to the `functions` directory (`cd functions`).
5.  Run `npm install` to install Firebase Functions dependencies.
6.  Configure Firebase for the project:
    *   Ensure `ask_agent_mcp/lib/firebase_options.dart` is correctly configured for your Firebase project. (This is usually done by `flutterfire configure`).
    *   Set up Firebase Authentication, Firestore, and Cloud Functions in your Firebase console.
    *   Deploy the Firebase Function in the `functions` directory using `firebase deploy --only functions`.
    *   (If using the Firebase Emulator Suite) Mention how to start it, e.g., `firebase emulators:start`. The current `main.dart` uses the emulator for Functions on `10.0.2.2:5001`.

### Running the Application

*   Ensure an emulator is running or a device is connected.
*   Run `flutter run` from the `ask_agent_mcp` directory.

## Project Structure

*   `ask_agent_mcp/`: Root directory of the Flutter application.
    *   `lib/main.dart`: Main application code, UI, and logic for calling the Firebase Function.
    *   `pubspec.yaml`: Flutter dependencies.
    *   `firebase_options.dart`: Firebase project configuration for the Flutter app.
*   `ask_agent_mcp/functions/`: Contains the Firebase Cloud Functions.
    *   `src/index.ts`: TypeScript code for the `askGemini` cloud function that interacts with the Gemini API.
    *   `package.json`: Node.js dependencies for the functions.

## (Optional) Backend Details

The `askGemini` Cloud Function in `functions/src/index.ts` is responsible for taking a user's question and fetching an answer from a Gemini model.
