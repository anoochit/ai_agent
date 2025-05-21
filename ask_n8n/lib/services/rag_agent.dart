import 'dart:convert';

import 'package:http/http.dart' as http;

class RagAgent {
  static const uri = 'http://localhost:5678/webhook/rag';

  Future<String> ask(String message, String sessionId) async {
    try {
      final res = await http.post(
        Uri.parse(uri),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"chatInput": message, "sessionId": sessionId}),
      );
      // log('status code = ${res.statusCode} ');
      // log('result = ${res.body} ');
      if (res.statusCode == 200) {
        return res.body;
      } else {
        throw ('Error');
      }
    } on http.ClientException catch (e) {
      throw (e.message);
    }
  }
}
