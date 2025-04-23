import 'package:ask_rag/services/rag_service.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

void main() {
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
      home: const MyHomePage(title: 'Ask! Kama Sutra'),
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
  final TextEditingController _questionController = TextEditingController(
    text: 'How to make woman love?',
  );
  String _answer = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Ask!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _questionController,
                decoration: InputDecoration(hintText: 'Enter your question'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => ask(),
                child: Text('Send'),
              ),
            ),

            (_answer.isNotEmpty)
                ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MarkdownWidget(shrinkWrap: true, data: _answer),
                )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Future<void> ask() async {
    setState(() {
      _answer = 'Loading...';
    });

    final result = await KamaSutraService.askKamaSutra(
      _questionController.text,
    );

    setState(() {
      _answer = result;
    });
  }
}
