import 'package:http/http.dart' as http;

import 'request.dart';
import 'response.dart';

class ApiException implements Exception {
  ApiException({
    required this.request,
    this.response,
    required this.clientException,
  });

  final Request request;
  final Response? response;
  final http.ClientException clientException;

  @override
  String toString() => clientException.message; // todo - better
}
