import 'exception.dart';
import 'interface.dart';
import 'request.dart';
import 'response.dart';

typedef RequestInterceptor = Future<RequestOrResponse> Function(Request);
typedef ResponseInterceptor = Future<Response> Function(Response);
typedef ErrorInterceptor = Future<ResponseOrException> Function(ApiException);

abstract class Interceptor {
  const Interceptor();

  Future<RequestOrResponse> onRequest(Request request) async => request;

  Future<Response> onResponse(Response response) async => response;

  Future<ResponseOrException> onError(ApiException exception) async =>
      exception;
}
