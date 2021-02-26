import 'interface.dart';

class Request implements RequestOrResponse{
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
  dynamic body;

  Request copyWith({
    Uri? url,
    Map<String, String>? headers,
    dynamic? body,
  }) =>
      Request(
        method: method,
        url: url ?? this.url,
        headers: headers ?? this.headers,
        body: body ?? this.body,
      );
}
