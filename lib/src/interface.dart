import 'response.dart';

abstract class Client {
  Future<Response<T>> head<T>(Uri url, {Map<String, String>? headers});

  Future<Response<T>> get<T>(Uri url, {Map<String, String>? headers});

  Future<Response<T>> post<T>(Uri url, {Map<String, String>? headers, Object? body});

  Future<Response<T>> put<T>(Uri url, {Map<String, String>? headers, Object? body});

  Future<Response<T>> patch<T>(Uri url,
      {Map<String, String>? headers, Object? body});

  Future<Response<T>> delete<T>(Uri url,
      {Map<String, String>? headers, Object? body});
}
