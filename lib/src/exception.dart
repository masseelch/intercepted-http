import 'interface.dart';
import 'request.dart';
import 'response.dart';

class ApiException implements Exception, ResponseOrException {
  ApiException({
    required this.request,
    this.response,
    required this.exception,
    required this.trace,
  });

  final Request request;
  final Response? response;
  final Object exception;
  final StackTrace trace;

  @override
  String toString() => exception.toString(); // todo - better
}
