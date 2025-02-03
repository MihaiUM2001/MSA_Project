import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/config.dart';

class AIPriceEstimator {
  final String apiKey = APIConfig.openAIKey;

  Future<double?> estimatePrice(String productName, String? imageUrl) async {
    final String prompt = "Estimate the price of a '$productName' in Romanian Leu (RON). "
        "If an image URL is provided, use it for better accuracy. "
        "Provide only a numerical price in RON.";

    try {
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "gpt-4o-mini", // 🔥 Use the latest model!
          "messages": [
            {
              "role": "system",
              "content": "You are an AI that estimates product prices in Romanian Leu (RON) based on product names and images."
            },
            {
              "role": "user",
              "content": [
                {"type": "text", "text": prompt},
                if (imageUrl != null)

                  {
                    "type": "image_url",
                    "image_url": {"url": imageUrl}
                  }
              ]
            }
          ],
          "max_tokens": 20,
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? priceText = data["choices"]?.first["message"]["content"];

        if (priceText != null) {
          final price = double.tryParse(priceText.replaceAll(RegExp(r'[^\d.]'), ''));
          return price;
        }
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }

    return null;
  }
  // New function for generating relevant swap preferences
  Future<List<String>> generateSwapPreferences(String productName) async {
    final String prompt = "Suggest one relevant swap item for a '$productName'. "
        "Provide the item name and add \"or similar\" to the end.";

    try {
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "system",
              "content": "You are an AI that suggests different swap items for a given product."
            },
            {
              "role": "user",
              "content": prompt,
            }
          ],
          "max_tokens": 50,
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? swapText = data["choices"]?.first["message"]["content"];

        if (swapText != null) {
          return swapText.split(',').map((e) => e.trim()).toList();
        }
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }

    return [];
  }
}
