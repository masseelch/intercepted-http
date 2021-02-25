class Response<T> {
  Response({
    required this.statusCode,
    required this.headers,
    required this.body,
  });

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
