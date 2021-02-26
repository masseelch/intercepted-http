import 'response.dart';

// Just a marker interface for Request/Response
abstract class RequestOrResponse {}

// Just a marker interface for Response/ApiException
abstract class ResponseOrException {}


abstract class Client {
  Future<Response> head(Uri url, {Map<String, String>? headers});

  Future<Response> get(Uri url, {Map<String, String>? headers});

  Future<Response> post(Uri url, {Map<String, String>? headers, Object? body});

  Future<Response> put(Uri url, {Map<String, String>? headers, Object? body});

  Future<Response> patch(Uri url,
      {Map<String, String>? headers, Object? body});

  Future<Response> delete(Uri url,
      {Map<String, String>? headers, Object? body});
}
