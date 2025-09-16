import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  // Use LAN IP for physical device; 10.0.2.2 for Android emulator
  final String baseUrl;

  ChatService({String? baseUrl}) : baseUrl = baseUrl ?? const String.fromEnvironment('CHAT_BASE_URL', defaultValue: 'http://10.0.2.2:5000');

  Future<Map<String, dynamic>> sendMessage(String message, {String? emotion, int? conversationId}) async {
    final url = Uri.parse("$baseUrl/chat");
    final body = {
      "message": message,
      "user_emotion": emotion,
      "conversation_id": conversationId
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception("Failed to send message: ${response.statusCode} ${response.body}");
  }
}


