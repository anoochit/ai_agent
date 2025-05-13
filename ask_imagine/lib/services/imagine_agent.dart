import 'dart:convert';
import 'dart:developer';

import 'package:ask_imagine/models/imagine_response.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/v4.dart';

class ImagineAgent {
  // base url
  final agentUri = 'http://10.0.2.2:8000';

  // create session
  Future<bool> createSession() async {
    // random session
    final sessionId = UuidV4().toString();

    // mock user
    final userId = 'u_123';

    // create session uri
    final uri = '$agentUri/apps/query_agent/users/$userId/sessions/$sessionId';

    //
    final headers = {'Content-Type': 'application/json'};

    try {
      // create session
      final res = await http.post(Uri.parse(uri), headers: headers);

      if (res.statusCode == 200) {
        return true;
      } else {
        throw ('Error Creating session ${res.statusCode} : ${res.body}');
      }
    } on http.ClientException catch (e) {
      throw ('Network Error creating session : ${e.message} ');
    }
  }

  // send message
  Future<String> sendMessage(String prompt) async {
    // create session uri
    final uri = '$agentUri/run';

    // header
    final headers = {'Content-Type': 'application/json'};

    // message
    final message = {
      "app_name": "query_agent",
      "user_id": "u_123",
      "session_id": "s_123",
      "streaming": false,
      "new_message": {
        "role": "user",
        "parts": [
          {"text": prompt},
        ],
      },
    };

    try {
      final res = await http.post(
        Uri.parse(uri),
        headers: headers,
        body: json.encode(message),
      );

      log(res.body);

      final data = imagineResponseFromJson(res.body);
      final result = data.last;
      final textResult = result.content!.parts![0].text;

      final regex = RegExp(r'(generated\/[^\s]+\.png)');

      final match = regex.firstMatch(textResult!);

      final imageUrl = '$agentUri/${match!.group(1)}';

      log('image url= ${imageUrl}');

      return imageUrl;
    } catch (e) {
      throw ('${e}');
    }
  }
}
