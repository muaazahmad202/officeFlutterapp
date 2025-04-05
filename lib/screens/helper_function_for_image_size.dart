import 'dart:io';
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';


Future<String> compressAndEncodeImage(File imageFile) async {
  // Adjust quality and dimensions as needed.
  final compressedBytes = await FlutterImageCompress.compressWithFile(
    imageFile.absolute.path,
    quality: 50,
    minWidth: 800,
    minHeight: 800,
  );

  if (compressedBytes != null) {
    return base64Encode(compressedBytes);
  } else {

    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }
}
