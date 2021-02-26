import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:intercepted_http/src/transformer.dart';

import 'exception.dart';
import 'interceptor.dart';
import 'interface.dart';
import 'request.dart';
import 'response.dart';
import 'util.dart';

class ApiClient implements Client {
  ApiClient({
    this.interceptors = const Interceptors(),
    this.transformer = const DefaultTransformer(),
    this.debug = false,
  }) : _client = http.Client();

  final Interceptors interceptors;
  final Transformer transformer;
  final http.Client _client;
  final bool debug;

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      _send('HEAD', url, headers);

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) =>
      _send('GET', url, headers);

  @override
  Future<Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _send('POST', url, headers, body);

  @override
  Future<Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _send('PUT', url, headers, body);

  @override
  Future<Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _send('PATCH', url, headers, body);

  @override
  Future<Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _send('DELETE', url, headers, body);

  Future<Response> _send(
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
    for (final interceptor in interceptors.enabledInterceptors) {
      _debug('Calling request-interceptor $interceptor');

      final requestOrResponse = await interceptor.onRequest(request);

      // If the current request-interceptor returned an response
      // cancel the request and return the response to the caller.
      if (requestOrResponse is Response) {
        _debug('\tcustom response detected');

        return requestOrResponse;
      }

      request = requestOrResponse as Request;
    }

    // Create the request to pass to the inner client.
    final httpRequest = http.Request(request.method, request.url);

    if (request.body != null) {
      httpRequest.body = await transformer.transformRequestData(request);

      if (!request.headers.containsKey('content-type')) {
        request.headers['content-type'] = defaultContentType(request);
      }
    }

    httpRequest.headers.addAll(request.headers);

    Response? response;
    try {
      // Hit the server.
      final httpResponse =
          await http.Response.fromStream(await _client.send(httpRequest));

      // Transform the data back.
      response = Response(
        request: request,
        statusCode: httpResponse.statusCode,
        headers: httpResponse.headers,
        body: await transformer.transformResponseData(httpResponse),
      );

      // Check if the response was successful.
      if (httpResponse.statusCode >= 400) {
        var message = 'Request to $url failed with status ${httpResponse.statusCode}';
        if (httpResponse.reasonPhrase != null) {
          message = '$message: ${httpResponse.reasonPhrase}';
        }
        throw http.ClientException('$message.', url);
      }
    } catch (e, t) {
      _debug('Exception: $e');

      // Catch client-exceptions thrown by the inner client. Pass it to the
      // error interceptors and return whatever they produce to the caller.
      ApiException exception = ApiException(
        request: request,
        response: response,
        exception: e,
        trace: t,
      );

      // Intercept the error. If any interceptor returns a response object it
      // is then returned to the caller. Otherwise throw the exception.
      for (final interceptor in interceptors.enabledInterceptors) {
        _debug('Calling error-interceptor $interceptor');

        final responseOrException = await interceptor.onError(exception);

        // If the current error-interceptor returned an response
        // cancel the request and return the response to the caller.
        if (responseOrException is Response) {
          _debug('\tcustom response detected');

          return responseOrException;
        }

        exception = responseOrException as ApiException;
      }

      // The error-interceptors did not cancel the exception. Throw it.
      throw exception;
    }

    // Intercept the response.
    for (final interceptor in interceptors.enabledInterceptors) {
      _debug('Calling response-interceptor $interceptor');

      response = await interceptor.onResponse(response!);
    }

    return response!;
  }

  void close() {
    _client.close();
  }

  _debug(String msg) {
    if (debug) print(msg);
  }
}
