import 'dart:convert';
import 'package:triplens/Home/Features/chat-bot/api/api_key.dart';
import 'package:triplens/Home/Features/chat-bot/data/chat_model.dart';
import 'package:http/http.dart' as http;

Future<ChatModel> sendRequestToGemini(ChatModel model) async {
  const String url =
      "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=${GeminiApiKey.api_key}";

  Map<String, dynamic> body;

  if (model.base64EncodedImage == null) {
    // طلب نص فقط
    body = {
      "contents": [
        {
          "parts": [
            {"text": model.message},
          ]
        }
      ]
    };
  } else {
    // طلب نص + صورة base64
    body = {
      "contents": [
        {
          "parts": [
            {"text": model.message},
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": model.base64EncodedImage,
              }
            }
          ]
        }
      ]
    };
  }

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    print("Status Code: ${response.statusCode}");
    print("Response: ${response.body}");

    final decoded = json.decode(response.body);

    String message;

    if (decoded != null &&
        decoded["candidates"] != null &&
        decoded["candidates"].isNotEmpty &&
        decoded["candidates"][0]["content"] != null &&
        decoded["candidates"][0]["content"]["parts"] != null &&
        decoded["candidates"][0]["content"]["parts"].isNotEmpty &&
        decoded["candidates"][0]["content"]["parts"][0]["text"] != null) {
      message = decoded["candidates"][0]["content"]["parts"][0]["text"];
    } else {
      message =
          "Error from Gemini: ${decoded['error']?['message'] ?? 'Unknown error'}";
    }

    return ChatModel(isMe: false, message: message);
  } catch (e) {
    print("Error: $e");
    return ChatModel(
      isMe: false,
      message: "⚠ Failed to communicate.",
    );
  }
}
