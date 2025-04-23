import 'dart:convert';

import 'package:http/http.dart' as http;

class KamaSutraService {
  static Future<String> askKamaSutra(String question) async {
    final uri = 'http://10.0.2.2:8000/search';

    try {
      final res = await http.post(
        Uri.parse(uri),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
        body: jsonEncode({'query': question}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return data['summary'] ?? 'No answer found';
      } else {
        throw Exception('Failed to load answer');
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
