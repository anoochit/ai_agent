import 'dart:developer';
import 'dart:typed_data';

import 'package:ask_vertex/services/vertextai_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _result = '';
  String _resultFunctionCall = '';
  Uint8List? _imageBytes;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: Column(
            children: [
              // loading
              (_isLoading)
                  ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const CircularProgressIndicator(),
                  )
                  : Container(),

              // gen text button
              ElevatedButton(
                onPressed: (_isLoading) ? null : () => generateText(context),
                child: Text('Generate Text'),
              ),

              // result text
              (_result != '') ? Text(_result) : Container(),

              // gen image button
              ElevatedButton(
                onPressed:
                    (_isLoading) ? null : () => generateImages(context, null),
                child: Text('Generate Image'),
              ),

              // image
              if (_imageBytes != null) Image.memory(_imageBytes!),

              ElevatedButton(
                onPressed:
                    (_isLoading)
                        ? null
                        : () => generateTextFunctionCall(context),
                child: Text('Function Call'),
              ),

              // function call result
              (_resultFunctionCall != '')
                  ? Text(_resultFunctionCall)
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  // generate text
  void generateText(BuildContext context) {
    final prompt = "Tell a story about a magic backpack";

    setState(() {
      _isLoading = true;
    });

    VertextaiServices.generateTextOnce(prompt)
        .then((value) {
          // Handle the generated text here
          setState(() {
            _result = value;
            _isLoading = false;
          });
        })
        .catchError((error) {
          // Handle any errors that occur during text generation
          log('Error generating text: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error generating text: $error')),
          );
        })
        .whenComplete(() {
          setState(() {
            _isLoading = false;
          });
        });
  }

  // generate image
  void generateImages(BuildContext context, String? prompt) {
    //
    prompt ??=
        "create a 3d rendered image of a pig "
        "with wings and a top hat flying over a happy "
        "futuristic scifi city with lots of greenery";

    setState(() {
      _isLoading = true;
    });

    VertextaiServices.generateImageOnce(prompt)
        .then((value) {
          // Handle the generated image URL here
          setState(() {
            if (value == null || value.isEmpty) {
              log('Error: No images were generated.');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: No images were generated.')),
              );
              return;
            }
            _imageBytes = value.first.bytesBase64Encoded;

            _isLoading = false;
          });
        })
        .catchError((error) {
          // Handle any errors that occur during image generation
          log('Error generating image: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error generating image: $error')),
          );
        });
  }

  // function call
  Future<void> generateTextFunctionCall(BuildContext context) async {
    final city = "What's the weather in London";

    setState(() {
      _isLoading = true;
    });

    // gemini function call
    final result = await VertextaiServices().generateTextFunctionCall(city);

    // create painting according weather data
    generateImages(
      context,
      'Generate an oil painting according to the weather condition in city : $result',
    );

    if (result != null) {
      setState(() {
        _resultFunctionCall = result;
        // _isLoading = false;
      });
    }
  }
}
