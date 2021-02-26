import 'exception.dart';
import 'interface.dart';
import 'request.dart';
import 'response.dart';

typedef RequestInterceptor = Future<RequestOrResponse> Function(Request);
typedef ResponseInterceptor = Future<Response> Function(Response);
typedef ErrorInterceptor = Future<ResponseOrException> Function(ApiException);

abstract class Interceptor {
  String get name;

  bool _enabled = true;

  bool get enabled => _enabled;

  void disable() => _enabled = false;

  void enable() => _enabled = true;

  Future<RequestOrResponse> onRequest(Request request) async => request;

  Future<Response> onResponse(Response response) async => response;

  Future<ResponseOrException> onError(ApiException exception) async =>
      exception;

  String toString() => name;
}

class Interceptors {
  const Interceptors() : _interceptors = const {};

  Interceptors.fromList(List<Interceptor> interceptors)
      : _interceptors = {for (var i in interceptors) i.name: i};

  final Map<String, Interceptor> _interceptors;

  void enableInterceptorByName(String name) {
    _interceptors[name]?.enable();
  }

  void disableInterceptorByName(String name) {
    _interceptors[name]?.disable();
  }

  Iterable<Interceptor> get enabledInterceptors =>
      _interceptors.values.where((i) => i.enabled);
}
