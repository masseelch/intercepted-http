import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:intercepted_http/src/transformer.dart';

import 'exception.dart';
import 'interceptor.dart';
import 'interface.dart';
import 'request.dart';
import 'response.dart';

class ApiClient implements Client {
  ApiClient({
    this.interceptors = const [],
    this.transformer = const DefaultTransformer(),
  }) : _client = http.Client();

  final List<Interceptor> interceptors;
  final Transformer transformer;
  final http.Client _client;

  @override
  Future<Response<T>> head<T>(Uri url, {Map<String, String>? headers}) =>
      _send<T>('HEAD', url, headers);

  @override
  Future<Response<T>> get<T>(Uri url, {Map<String, String>? headers}) =>
      _send<T>('GET', url, headers);

  @override
  Future<Response<T>> post<T>(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _send<T>('POST', url, headers, body);

  @override
  Future<Response<T>> put<T>(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _send<T>('PUT', url, headers, body);

  @override
  Future<Response<T>> patch<T>(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _send<T>('PATCH', url, headers, body);

  @override
  Future<Response<T>> delete<T>(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _send<T>('DELETE', url, headers, body);

  Future<Response<T>> _send<T>(
    String method,
    Uri url,
    Map<String, String>? headers, [
    Object? body,
  ]) async {
    // Create the request for the interceptors.
    Request request = Request(
      method: method,
      url: url,
      headers: headers ?? {},
      body: body,
    );

    // Intercept the request.
    for (final interceptor in interceptors.where((i) => i.onRequest != null)) {
      request = await interceptor.onRequest!(request);

      // todo - interceptors cannot cancel the request for now
      // // If any of the interceptors did not return a request object, cancel.
      // if (request == null) {
      //
      //   return null;
      // }
    }

    // Create the request to pass to the inner client.
    final httpRequest = http.Request(request.method, request.url);
    httpRequest.headers.addAll(request.headers);

    if (request.body != null) {
      httpRequest.body = await transformer.transformRequestData(request);
    }

    Response<T>? response;
    try {
      // Hit the server.
      final httpResponse =
          await http.Response.fromStream(await _client.send(httpRequest));

      // Transform the data back.
      response = Response<T>(
        request: request,
        statusCode: httpResponse.statusCode,
        headers: httpResponse.headers,
        body: await transformer.transformResponseData(httpResponse),
      );
    } catch (e) {
      // Catch client-exceptions thrown by the inner client. Pass it to the
      // error interceptors and return whatever they produce to the caller.
      final exception = ApiException(
        request: request,
        response: response,
        exception: e,
      );

      // Intercept the error. If any interceptors returns an response object it
      // is then returned to the caller. If no response object gets returned the
      // given exception is thrown to the caller.
      for (final interceptor in interceptors.where((i) => i.onError != null)) {
        response = await interceptor.onError!(exception) as Response<T>?;

        // If any of the interceptors returned a response object get it to the
        // caller.
        if (response != null) {
          return response;
        }
      }

      // The error-interceptors did not cancel the exception. Throw it.
      throw exception;
    }

    // Intercept the response.
    for (final interceptor
        in interceptors.where((i) => i.onResponse != null).toList().reversed) {
      response = await interceptor.onResponse!(response!) as Response<T>?;

      // todo - interceptors cannot cancel the request for now
      // // If any of the interceptors did not return a response object cancel.
      // if (response == null) {
      //   return null;
      // }
    }

    return response!;
  }

  void close() {
    _client.close();
  }
}
