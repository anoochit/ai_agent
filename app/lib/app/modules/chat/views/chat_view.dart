import 'dart:developer';

import 'package:app/app/routes/app_pages.dart';
import 'package:app/app/services/chat.dart';
import 'package:app/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask!'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        actions: [signOutButton()],
      ),
      body: Column(children: [messageList(), textInputBox(context)]),
    );
  }

  IconButton signOutButton() {
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () => signOut(),
    );
  }

  Widget messageList() {
    return StreamBuilder(
      stream: ChatService.streamMessages(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          final messages = snapshot.data?.docs;

          log('total messages = ${messages!.length}');

          if (messages.isEmpty) {
            return const Center(child: Text('No messages yet'));
          }

          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (controller.scrollController.hasClients) {
              controller.scrollController.animateTo(
                controller.scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });

          return Expanded(
            child: ListView.builder(
              controller: controller.scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final data = messages[index].data() as Map<String, dynamic>?;
                final prompt = data?['prompt'] as String?;
                final response = data?['response'] as String?;
                final status = data?['status'] as bool?;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        prompt ?? '...',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    if (status == true && response != null)
                      ListTile(title: Text(response)),
                    const Divider(),
                  ],
                );
              },
            ),
          );
        }

        return const Center(child: Text('Waiting for messages...'));
      },
    );
  }

  Container textInputBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.inversePrimary,
            width: 1.0,
          ),
        ),
      ),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
            child: TextFormField(
              controller: controller.textMessageController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefix: SizedBox(width: 16),
                hintText: 'Type your question here!',
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
              ),
              minLines: 1,
              maxLines: 10,
              textInputAction: TextInputAction.send,
              onFieldSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = controller.textMessageController.text.trim();
    if (message.isNotEmpty) {
      controller.sendMessage(message);
      controller.textMessageController.clear();

      FocusScope.of(Get.context!).unfocus();
    }
  }

  void signOut() {
    auth
        .signOut()
        .then((value) {
          Get.offAllNamed(Routes.LOGIN);
        })
        .catchError((error) {
          log("Sign out error: $error");
          Get.snackbar(
            'Sign Out Error',
            'Could not sign out. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
          );
        });
  }
}
