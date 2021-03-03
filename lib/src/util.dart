import 'package:http_parser/http_parser.dart';

import 'request.dart';

String defaultContentType(Request request) {
  if (request.body is String) {
    return 'text/plain';
  } else if (request.body is Map) {
    return 'application/json';
  } else {
    throw ArgumentError('Invalid request body "${request.body}".');
  }
}

String mapToQuery(Map map) {
  var pairs = <List<String>>[];
  map.forEach((key, value) => pairs.add([
        Uri.encodeQueryComponent(key.toString()),
        Uri.encodeQueryComponent(value.toString()),
      ]));
  return pairs.map((pair) => '${pair[0]}=${pair[1]}').join('&');
}

bool hasJsonContentType(Map<String, String> headers) {
  if (headers.containsKey('content-type')) {
    final contentType = MediaType.parse(headers['content-type']!);
    if (contentType.mimeType == 'application/json') {
      return true;
    }
  }

  return false;
}
