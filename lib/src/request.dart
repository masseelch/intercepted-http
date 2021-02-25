import 'package:http/http.dart' as http;

class Request {
  Request({
    required this.method,
    required this.url,
    required this.headers,
    this.body,
  });

  // The method of this request.
  final String method;

  // The url of this request.
  Uri url;

  // The headers of this request.
  Map<String, String> headers;

  // The body of this request.
  Object? body;

  http.Request toHttpRequest() {
    final request = http.Request(method, url);

    request.headers.addAll(headers);

    if (body != null) {
      if (body is String) {
        request.body = body as String;
      } else if (body is List) {
        request.bodyBytes = (body as List).cast<int>();
      } else if (body is Map) {
        request.bodyFields = (body as Map).cast<String, String>();
      } else {
        throw ArgumentError('Invalid request body "$body".');
      }
    }

    return request;
  }
}
