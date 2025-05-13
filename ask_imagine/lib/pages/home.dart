import 'package:ask_imagine/services/imagine_agent.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController promptTextController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String error = '';

  // final prompt = 'White tiger laying down on the rock';
  final prompt =
      'a comodo lizard walking on a tree column in the forest on the dawn of the sun light';

  bool isLoading = false;

  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    // mock prompt
    promptTextController.text = prompt;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Imagine')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // input form
            Form(
              key: formKey,
              child: TextFormField(
                controller: promptTextController,
                decoration: InputDecoration(hintText: 'Enter your idea ...'),
                enabled: (!isLoading),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your idea';
                  }
                  return null;
                },
                maxLines: null,
                minLines: 2,
              ),
            ),
            FilledButton(
              onPressed: (!isLoading) ? () => buildImage() : null,
              child: Text('Let\'s Imagine!'),
            ),

            // log message
            Text(error),

            // loading
            (isLoading) ? CircularProgressIndicator() : Container(),

            // result
            (imageUrl.isNotEmpty)
                ? Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Image.network(imageUrl),
                )
                : Container(),
          ],
        ),
      ),
    );
  }

  Future<void> buildImage() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final prompt = promptTextController.text.trim();
      try {
        final result = await ImagineAgent().sendMessage(prompt);
        log('result = $result');
        setState(() {
          imageUrl = result;
        });
      } catch (e) {
        setState(() {
          error = '${e}';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
