import 'package:app/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  // send message
  static Future<void> sendMessage(String message) async {
    try {
      final uid = auth.currentUser!.uid;
      final data = {
        'prompt': message,
        'createdAt': DateTime.now(),
        'response': null,
        'status': null,
        'uid': uid,
      };
      await firestore
          .collection('chats')
          .doc(uid)
          .collection('messages')
          .add(data);
    } catch (e) {
      throw ('Error', e.toString());
    }
  }

  // stream message
  static Stream<QuerySnapshot> streamMessages() {
    //
    try {
      final uid = auth.currentUser!.uid;

      return firestore
          .collection('chats')
          .doc(uid)
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .snapshots();
    } catch (e) {
      throw ('Error', e.toString());
    }
  }
}
