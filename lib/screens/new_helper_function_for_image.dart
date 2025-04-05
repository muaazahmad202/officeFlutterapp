import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Fixes a Base64 string by removing data URI prefixes, trimming whitespace,
/// and padding the string to a multiple of 4 if needed.
String fixBase64(String base64Str) {
  if (base64Str.contains(',')) {
    base64Str = base64Str.split(',').last;
  }
  base64Str = base64Str.trim();
  int remainder = base64Str.length % 4;
  if (remainder > 0) {
    base64Str = base64Str.padRight(base64Str.length + (4 - remainder), '=');
  }
  return base64Str;
}

/// Returns a widget that displays [imageStr] as either a network image
/// (if it starts with "http") or a Base64‐decoded image (otherwise).
Widget buildProductImage(String imageStr, {BoxFit fit = BoxFit.contain}) {
  if (imageStr.startsWith("http")) {
    return Image.network(
      imageStr,
      fit: fit,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
    );
  } else {
    try {
      final fixed = fixBase64(imageStr);
      final Uint8List bytes = base64Decode(fixed);
      return Image.memory(
        bytes,
        fit: fit,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
      );
    } catch (e) {
      debugPrint("Error decoding Base64 image: $e");
      return const Icon(Icons.broken_image, size: 50);
    }
  }
}
