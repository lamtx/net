import 'dart:io';

final class HttpHeadersResponse {
  var _statusCode = 0;
  HttpHeaders? _headers;

  HttpHeaders get headers =>
      _headers ?? (throw StateError("Headers has not set."));

  int get statusCode => _statusCode;
}

extension HttpHeadersResponseInternalMethod on HttpHeadersResponse {
  void set(HttpClientResponse response) {
    _statusCode = response.statusCode;
    _headers = response.headers;
  }
}
