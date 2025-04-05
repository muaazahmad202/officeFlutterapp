import 'dart:io';
import 'package:http/io_client.dart';

HttpClient createHttpClient() {
  final HttpClient httpClient = HttpClient();
  httpClient.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;
  return httpClient;
}

IOClient createIOClient() {
  return IOClient(createHttpClient());
}
