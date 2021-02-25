import 'package:intercepted_http/intercepted_http.dart';

class Response<T> {
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
  T body;

  // Response.fromHttpResponse(http.Response response)
  //     : statusCode = response.statusCode,
  //       headers = response.headers,
  //       // bodyBytes = response.bodyBytes,
  //       body = response.body as T;
}
