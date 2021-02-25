import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'request.dart';

abstract class Transformer<T> {
  Future<String> transformRequestData(Request request);

  Future<T> transformResponseData(http.Response response);
}

class DefaultTransformer implements Transformer {
  const DefaultTransformer();

  @override
  Future<String> transformRequestData(Request request) async {
    if (request.body != null) {
      if (request.body is String) {
        return request.body;
      } else if (request.body is Map) {
        if (_hasJsonContentType(request.headers)) {
          return jsonEncode(request.body as Map);
        }

        return _mapToQuery((request.body as Map).cast<String, String>());
      } else {
        throw ArgumentError('Invalid request body "${request.body}".');
      }
    }

    throw Exception('LogicException');
  }

  @override
  Future transformResponseData(http.Response response) async {
    // Transform data based on a given content-type.
    if (_hasJsonContentType(response.headers)) {
        return jsonDecode(response.body);
    }

    return response.body;
  }
}

String _mapToQuery(Map<String, String> map) {
  var pairs = <List<String>>[];
  map.forEach((key, value) => pairs
      .add([Uri.encodeQueryComponent(key), Uri.encodeQueryComponent(value)]));
  return pairs.map((pair) => '${pair[0]}=${pair[1]}').join('&');
}

bool _hasJsonContentType(Map<String, String> headers) {
  if (headers.containsKey('content-type')) {
    final contentType = MediaType.parse(headers['content-type']!);
    if (contentType.mimeType == 'application/json') {
      return true;
    }
  }

  return false;
}
