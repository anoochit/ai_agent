import 'dart:convert';

import 'package:ask_n8n/models/chat_message.dart';
import 'package:ask_n8n/services/rag_agent.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final String sessionId = Uuid().v4();
final List<ChatMessage> messages = <ChatMessage>[];

class _HomePageState extends State<HomePage> {
  bool isLoad = false;
  TextEditingController askTextController = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('RAG')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: scrollController,
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  color:
                      (messages[(messages.length - 1) - index].isUser)
                          ? Theme.of(context).colorScheme.inversePrimary
                          : Theme.of(context).colorScheme.primaryContainer,
                  elevation: 0.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MarkdownWidget(
                      data: messages[(messages.length - 1) - index].message,
                      shrinkWrap: true,
                    ),
                  ),
                );
              },
            ),
          ),
          (isLoad) ? CircularProgressIndicator() : Container(),
          Container(
            padding: EdgeInsets.all(8.0),
            height: 64,
            child: TextFormField(
              controller: askTextController,
              decoration: InputDecoration(
                hintText: 'เขียนคำถาม...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onFieldSubmitted: (value) => ask(value),
              enabled: (!isLoad),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> ask(String message) async {
    setState(() {
      isLoad = true;
      messages.add(ChatMessage(message: message, isUser: true));
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });

    try {
      final result = await RagAgent().ask(message, sessionId);
      final output = jsonDecode(result);
      messages.add(
        ChatMessage(message: output.first["output"].toString(), isUser: false),
      );
    } finally {
      askTextController.clear();
      setState(() {
        isLoad = false;
      });
    }
  }
}
