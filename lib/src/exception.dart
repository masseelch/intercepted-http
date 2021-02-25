import 'request.dart';
import 'response.dart';

class ApiException implements Exception {
  ApiException({
    required this.request,
    this.response,
    required this.exception,
  });

  final Request request;
  final Response? response;
  final Object exception;

  @override
  String toString() => exception.toString(); // todo - better
}
