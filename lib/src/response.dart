import 'dart:typed_data';

import 'package:http/http.dart' as http;

class Response {
  Response({
    required this.statusCode,
    required this.headers,
    required this.bodyBytes,
    required this.body,
  });

  final int statusCode;

  // The response headers.
  Map<String, String> headers;

  // The response body in bytes.
  Uint8List bodyBytes;

  // The response body as String.
  String body;

  Response.fromHttpResponse(http.Response response)
      : statusCode = response.statusCode,
        headers = response.headers,
        bodyBytes = response.bodyBytes,
        body = response.body;
}
