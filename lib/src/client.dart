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
  }) : _client = http.Client();

  final Interceptors interceptors;
  final Transformer transformer;
  final http.Client _client;

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      _send(Request(
        method: 'HEAD',
        url: url,
        headers: headers,
      ));

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) =>
      _send(Request(
        method: 'GET',
        url: url,
        headers: headers,
      ));

  @override
  Future<Response> post(Uri url, {Map<String, String>? headers, Object? body}) =>
      _send(Request(
        method: 'POST',
        url: url,
        headers: headers,
        body: body,
      ));

  @override
  Future<Response> put(Uri url, {Map<String, String>? headers, Object? body}) =>
      _send(Request(
        method: 'PUT',
        url: url,
        headers: headers,
        body: body,
      ));

  @override
  Future<Response> patch(Uri url, {Map<String, String>? headers, Object? body}) =>
      _send(Request(
        method: 'PATCH',
        url: url,
        headers: headers,
        body: body,
      ));

  @override
  Future<Response> delete(Uri url, {Map<String, String>? headers, Object? body}) =>
      _send(Request(
        method: 'DELETE',
        url: url,
        headers: headers,
        body: body,
      ));

  Future<Response> multipart(Uri url, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) =>
      _send(Request(
        method: 'POST',
        url: url,
        multipart: true,
        headers: headers,
        fields: fields,
        files: files,
      ));

  Future<Response> _send(Request request) async {
    // Intercept the request.
    for (final interceptor in interceptors.enabledInterceptors) {
      final requestOrResponse = await interceptor.onRequest(request);

      // If the current request-interceptor returned an response
      // cancel the request and return the response to the caller.
      if (requestOrResponse is Response) {
        return requestOrResponse;
      }

      request = requestOrResponse as Request;
    }

    // Create the request to pass to the inner client. This method will set the body / fields / files accordingly.
    final httpRequest = await _createHttpRequest(request);

    // Make sure the headers are all transferred.
    httpRequest.headers.addAll(request.headers);

    Response? response;
    try {
      // Hit the server.
      final httpResponse = await http.Response.fromStream(await _client.send(httpRequest));

      // Transform the data back.
      response = Response(
        request: request,
        statusCode: httpResponse.statusCode,
        headers: httpResponse.headers,
        body: await transformer.transformResponseData(httpResponse),
      );

      // Check if the response was successful.
      if (httpResponse.statusCode >= 400) {
        var message = 'Request to ${request.url} failed with status ${httpResponse.statusCode}';
        if (httpResponse.reasonPhrase != null) {
          message = '$message: ${httpResponse.reasonPhrase}';
        }
        throw http.ClientException('$message.', request.url);
      }
    } catch (e, t) {
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
        final responseOrException = await interceptor.onError(exception);

        // If the current error-interceptor returned an response
        // cancel the request and return the response to the caller.
        if (responseOrException is Response) {
          return responseOrException;
        }

        exception = responseOrException as ApiException;
      }

      // The error-interceptors did not cancel the exception. Throw it.
      throw exception;
    }

    // Intercept the response.
    for (final interceptor in interceptors.enabledInterceptors) {
      response = await interceptor.onResponse(response!);
    }

    return response!;
  }

  Future<http.BaseRequest> _createHttpRequest(Request request) async {
    if (request.multipart) {
      final httpRequest = http.MultipartRequest(request.method, request.url);

      httpRequest.fields.addAll(request.fields);
      httpRequest.files.addAll(request.files);

      return httpRequest;
    } else {
      final httpRequest = http.Request(request.method, request.url);

      if (request.body != null) {
        if (!request.headers.containsKey('content-type')) {
          request.headers['content-type'] = defaultContentType(request);
        }

        httpRequest.body = await transformer.transformRequestData(request);
      }

      return httpRequest;
    }
  }

  void close() {
    _client.close();
  }
}
