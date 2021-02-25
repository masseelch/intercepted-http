import 'exception.dart';
import 'request.dart';
import 'response.dart';

typedef OnRequest = Future<Request?> Function(Request);
typedef OnResponse = Future<Response?> Function(Response);
typedef OnError = Future<Response?> Function(ApiException);

class Interceptor {
  const Interceptor({this.onRequest, this.onResponse, this.onError});

  final OnRequest? onRequest;
  final OnResponse? onResponse;
  final OnError? onError;
}
