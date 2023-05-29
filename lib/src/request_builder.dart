import 'body.dart';
import "credentials.dart";
import 'http_method.dart';
import 'request.dart';
import 'string_body.dart';

final class RequestBuilder {
  RequestBuilder(String url) : _url = url;

  final String _url;
  HttpMethod _method = HttpMethod.get;
  Body? _body;
  Map<String, Object?> _params = const {};
  final Map<String, String> _headers = {};
  Credentials? _credentials;
  Map<String, String> _responseHeaders = const {};

  Credentials? get credentials => _credentials;

  RequestBuilder authorize(Credentials? credentials) {
    _credentials = credentials;
    return this;
  }

  RequestBuilder body(Body? body) {
    _body = body;
    return this;
  }

  RequestBuilder jsonBody(Map<String, Object?> object) {
    _body = StringBody.json(object);
    return this;
  }

  RequestBuilder urlEncodedBody(Map<String, Object?> object) {
    _body = StringBody.urlEncoded(object);
    return this;
  }

  RequestBuilder params(Map<String, Object?> params) {
    _params = params;
    return this;
  }

  RequestBuilder method(HttpMethod method) {
    _method = method;
    return this;
  }

  RequestBuilder headers(Map<String, String> headers) {
    _headers.addAll(headers);
    return this;
  }

  RequestBuilder responseHeaders(Map<String, String> headers) {
    _responseHeaders = headers;
    return this;
  }

  Request build() => Request(
        url: _url,
        method: _method,
        body: _body,
        params: _params,
        headers: _headers,
        credentials: _credentials,
        responseHeaders: _responseHeaders,
      );
}
