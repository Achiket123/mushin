import 'dart:convert';
import 'dart:io';

import 'package:control/main.dart';
import 'package:dotenv/dotenv.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future<bool> uploadPhoto(String filePath) async {
    final apiKey = dotenv.get("API_KEY");
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=$apiKey',
    );

    try {
      // Read file and encode to base64
      final bytes = await File(filePath).readAsBytes();
      final base64Image = base64Encode(bytes);

      // Prepare JSON body
      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Give me in one word answer to the question. Can you see Greenery and nature in the image? just yes and no.",
              },
              {
                "inlineData": {
                  "mimeType": "image/jpeg", // or image/png
                  "data": base64Image,
                },
              },
            ],
          },
        ],
      });

      // Create POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // Print result
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final res =
            data['candidates'][0]['content']['parts'][0]['text'].toString();

        debugPrint("Response: ${response.body}");
        return res.toLowerCase() == "yes" ? true : false;
      } else {
        debugPrint("Error: ${response.statusCode}");
        debugPrint("Response: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Exception occurred: $e");
      return false;
    }
  }
}
