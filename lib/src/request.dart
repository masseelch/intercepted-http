import 'package:http/http.dart' show MultipartFile;

import 'interface.dart';

class Request implements RequestOrResponse {
  Request({
    required this.method,
    required this.url,
    this.multipart = false,
    Map<String, String>? headers,
    Map<String, String>? fields,
    List<MultipartFile>? files,
    this.body,
  }) : headers = headers ?? {}, fields = fields ?? {}, files = files ?? [];

  // The method of this request.
  final String method;

  // Is this request a multipart request.
  final bool multipart;

  // The url of this request.
  Uri url;

  // The headers of this request.
  Map<String, String> headers;

  // The fields of this request (in case of a multipart request).
  Map<String, String> fields;

  // The files of this request (in case of a multipart request).
  List<MultipartFile> files;

  // The body of this request.
  dynamic body;

  Request copyWith({
    Uri? url,
    Map<String, String>? headers,
    dynamic? body,
    Map<String, String>? fields,
    List<MultipartFile>? files,
  }) =>
      Request(
        method: method,
        multipart: multipart,
        url: url ?? this.url,
        headers: headers ?? this.headers,
        body: body ?? this.body,
        fields: fields ?? this.fields,
        files: files ?? this.files,
      );
}
