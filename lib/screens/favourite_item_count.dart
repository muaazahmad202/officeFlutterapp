import 'dart:convert';

import 'package:flutter/material.dart';

import 'http_client_for_test.dart';

class FavoriteBadge extends StatelessWidget {
  final String userId;
  final VoidCallback onPressed;

  const FavoriteBadge({
    Key? key,
    required this.userId,
    required this.onPressed,
  }) : super(key: key);

  Future<int> getFavoriteCount(String userId) async {
    final client = createIOClient();
    final String url = "https://darnalbrojewelry.com/api/Favorite?userId=$userId";
    final response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.length;
    } else {
      throw Exception("Failed to load favorites (status ${response.statusCode})");
    }
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: getFavoriteCount(userId),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data! : 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.black),
              onPressed: onPressed,
            ),
            if (count > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
