import 'dart:developer';

import 'package:ask/firebase_options.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

FirebaseFunctions functions = FirebaseFunctions.instanceFor(
  region: 'us-central1',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // use firebase emulator
  FirebaseFunctions.instance.useFunctionsEmulator('10.0.2.2', 5001);

  // run app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'AI Agent App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController questionController = TextEditingController();
  String forcast = '';

  @override
  Widget build(BuildContext context) {
    questionController.text = 'What is the weather in London?';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Ask Weather Agent',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: questionController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'What is the weather in London?',
                ),
              ),
            ),
            SizedBox(height: 20),
            (forcast != '')
                ? Text(
                  forcast,
                  style: Theme.of(context).textTheme.headlineSmall,
                )
                : Container(),
            ElevatedButton(onPressed: () => ask(), child: const Text('Ask!')),
          ],
        ),
      ),
    );
  }

  // ask gemini function
  Future<void> ask() async {
    {
      try {
        // get the question from the text field
        final String question =
            questionController.text
                .trim(); // Replace with your text field value
        // ask gemini
        final HttpsCallable callable = functions.httpsCallable('askGemini');
        final HttpsCallableResult result = await callable.call({
          'question': question,
        });

        // print the result
        log('Success: ${result.data?.toString() ?? 'null'}');

        // Display the result in a dialog or any other way you prefer
        setState(() {
          forcast = result.data?.toString() ?? '';
        });
      } on FirebaseFunctionsException catch (e) {
        // Handle Firebase Functions specific errors
        log(
          'FirebaseFunctionsException Error calling function: ${e.toString()}',
        );
        log('Error code: ${e.code}');
        log('Error message: ${e.message}');
        log('Error details: ${e.details}');
      } catch (e) {
        // Handle any other generic errors
        log('Generic Error calling function: ${e.toString()}');
      }
    }
  }
}
