import 'package:intercepted_http/intercepted_http.dart';

class Response implements RequestOrResponse, ResponseOrException {
  Response({
    required this.request,
    required this.statusCode,
    required this.headers,
    required this.body,
  });

  final Request request;

  final int statusCode;

  // The response headers.
  Map<String, String> headers;

  // The response body.
  dynamic body;
}
