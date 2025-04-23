import 'package:app/app/services/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  RxList<String> messages = <String>[].obs;
  RxBool isLoading = false.obs;

  TextEditingController textMessageController = TextEditingController();

  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    // Initialize load older messages
    loadStreamMessage();
  }

  Stream<QuerySnapshot> loadStreamMessage() {
    // Load messages from the stream
    return ChatService.streamMessages();
  }

  Future<void> sendMessage(String message) async {
    if (message.isEmpty) return;
    isLoading.value = true;
    try {
      messages.add(message);
      await ChatService.sendMessage(message);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
