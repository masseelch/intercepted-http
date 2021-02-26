import 'dart:convert';

import 'package:http/http.dart' as http;

import 'request.dart';
import 'util.dart';

abstract class Transformer {
  Future<String> transformRequestData(Request request);

  Future transformResponseData(http.Response response);
}

class DefaultTransformer implements Transformer {
  const DefaultTransformer();

  @override
  Future<String> transformRequestData(Request request) async {
    if (request.body != null) {
      if (request.body is String) {
        return request.body;
      } else if (request.body is Map) {
        if (hasJsonContentType(request.headers)) {
          return jsonEncode(request.body as Map);
        }

        return mapToQuery((request.body as Map).cast<String, String>());
      } else {
        throw ArgumentError('Invalid request body "${request.body}".');
      }
    }

    throw Exception('LogicException');
  }

  @override
  Future transformResponseData(http.Response response) async {
    // Transform data based on a given content-type.
    if (hasJsonContentType(response.headers)) {
      return jsonDecode(response.body);
    }

    return response.body;
  }
}
