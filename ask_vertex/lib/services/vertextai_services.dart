import 'dart:developer';
import 'dart:typed_data';

import 'package:ask_vertex/services/weather_service.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/services.dart';

class VertextaiServices {
  // generate text and return a stream of strings
  Stream<String> generateTextStream(String prompt) {
    final model = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-2.0-flash',
    );

    return model
        .generateContentStream([Content.text(prompt)])
        .map((event) => event.text ?? '');
  }

  // generate text and return a single string
  static Future<String> generateTextOnce(String prompt) async {
    final model = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-2.0-flash',
    );
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }

  // generate image and return a stream of strings
  static Future<List<ImagenInlineImage>?> generateImageOnce(
    String prompt,
  ) async {
    final model = FirebaseVertexAI.instance.imagenModel(
      model: 'imagen-3.0-generate-002',
      generationConfig: ImagenGenerationConfig(
        // Set the image size to 512x512
        aspectRatio: ImagenAspectRatio.square1x1,
        // Set the number of images to generate
        numberOfImages: 1,
        addWatermark: true,
      ),
    );

    // To generate an image, call `generateImages` with the text prompt
    final response = await model.generateImages(prompt);

    if (response.images.isNotEmpty) {
      final image = response.images;
      // Process the image
      return image;
    } else {
      // Handle the case where no images were generated
      log('Error: No images were generated.');
      return null;
    }
  }

  // edit image with prompt
  Future<Uint8List?> generateEditedImage(String prompt, Uint8List image) async {
    // Changed return type
    final generationConfig = GenerationConfig(
      maxOutputTokens: 8192,
      temperature: 1,
      topP: 0.95,
    );

    final model = FirebaseVertexAI.instanceFor(
      location: 'us-central1',
    ).generativeModel(
      model: 'gemini-2.0-flash-exp',
      generationConfig: generationConfig,
    );

    final imageRef = InlineDataPart('image/png', image);

    final response = await model.generateContent([
      Content('user', [TextPart(prompt), imageRef]),
    ]);

    // Extract the image bytes from the response
    try {
      final imagePart =
          response.candidates.first.content.parts
              .whereType<InlineDataPart>()
              .firstOrNull;
      if (imagePart != null) {
        log('return image');
        return imagePart.bytes;
      }
      log('no image retrun');
    } catch (e) {
      log('Error extracting image from response: $e');
    }
    return null; // Return null if no image is found or an error occurs
  }

  // function call to generate text and return a stream of strings
  Future<String?> generateTextFunctionCall(String prompt) async {
    final model = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-2.0-flash',
      // Provide the function declaration to the model.
      tools: [
        Tool.functionDeclarations([fetchWeatherTool]),
      ],
    );

    return await model
        .generateContent([Content.text(prompt)])
        .then((response) async {
          // Handle the response
          final functionCall = response.functionCalls;
          if (functionCall.isNotEmpty) {
            // Call the function with the provided arguments
            final functionName = functionCall.first.name;
            if (functionName == 'fetchWeather') {
              final city = functionCall.first.args['city'].toString();
              if (city.isNotEmpty) {
                return await fetchWeather(city)
                    .then((weatherResponse) async {
                      // Handle the weather response
                      final summary = await generateTextOnce(
                        'Summary following weather forcast \n\n $weatherResponse',
                      );
                      log(summary);
                      return summary;
                    })
                    .catchError((error) {
                      // Handle any errors that occur during the function call
                      log('Error fetching weather: $error');
                      throw Exception('Error fetching weather: $error');
                    });
              } else {
                // Handle the case where the city argument is missing
                log('City argument is missing.');
                throw Exception('City argument is missing.');
              }
            } else {
              // Handle the case where the function name is not recognized
              log('Function name not recognized: $functionName');
              return response.text;
            }
          } else {
            // Handle the case where no function call was made
            log('No function call made.');
            return response.text;
          }
        })
        .catchError((error) {
          // Handle any errors that occur during text generation
          log('Error generating text: $error');
          return null;
        });
  }

  // weather function declaration
  // This function declaration is used to define the function that the model can call.
  final fetchWeatherTool = FunctionDeclaration(
    'fetchWeather',
    'Get the weather conditions for a specific city.',
    parameters: {
      'city': Schema.string(
        description: 'The name of the city to get the weather for.',
      ),
    },
  );

  Future<String> fetchWeather(String city) async {
    // get the weather for a specific city
    final apiResponse = await WeatherService.cityWeather(city: city);
    return apiResponse;
  }
}
