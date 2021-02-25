import 'dart:async';

import 'package:http/http.dart' as http;

import 'exception.dart';
import 'interceptor.dart';
import 'interface.dart';
import 'request.dart';
import 'response.dart';

class ApiClient implements Client {
  ApiClient({this.interceptors = const []}) : _client = http.Client();

  final List<Interceptor> interceptors;
  final http.Client _client;

  @override
  Future<Response?> head(Uri url, {Map<String, String>? headers}) =>
      _send('HEAD', url, headers);

  @override
  Future<Response?> get(Uri url, {Map<String, String>? headers}) =>
      _send('GET', url, headers);

  @override
  Future<Response?> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _send('POST', url, headers, body);

  @override
  Future<Response?> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _send('PUT', url, headers, body);

  @override
  Future<Response?> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _send('PATCH', url, headers, body);

  @override
  Future<Response?> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _send('DELETE', url, headers, body);

  Future<Response?> _send(
    String method,
    Uri url,
    Map<String, String>? headers, [
    Object? body,
  ]) async {
    // Create the request for the interceptors.
    Request? request = Request(
      method: method,
      url: url,
      headers: headers ?? {},
      body: body,
    );

    // Intercept the request.
    for (final interceptor in interceptors.where((i) => i.onRequest != null)) {
      request = await interceptor.onRequest!(request!);

      // If any of the interceptors did not return a request object cancel.
      if (request == null) {
        return null;
      }
    }

    // Hit the server.
    Response? response;
    try {
      response = Response.fromHttpResponse(
        await http.Response.fromStream(
          await _client.send(request!.toHttpRequest()),
        ),
      );
    } on http.ClientException catch (e) {
      // Catch client-exceptions thrown by the inner client. Pass it to the
      // error interceptors and return whatever they produce to the caller.
      final exception = ApiException(
        request: request!,
        response: response,
        clientException: e,
      );

      // Intercept the error. If any interceptors returns an response object it
      // is then returned to the caller. If no response object gets returned the
      // given exception is thrown to the caller.
      for (final interceptor in interceptors.where((i) => i.onError != null)) {
        response = await interceptor.onError!(exception);

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
    for (final interceptor in interceptors.where((i) => i.onResponse != null)) {
      response = await interceptor.onResponse!(response!);

      // If any of the interceptors did not return a response object cancel.
      if (response == null) {
        return null;
      }
    }

    return response;
  }

  void close() {
    _client.close();
  }
}
