import 'body.dart';
import "credentials.dart";
import 'string_body.dart';
import 'utilities.dart';

enum HttpMethod { get, post, put, patch, head, delete }

class Request {
  Request({
    required this.url,
    required this.method,
    this.body,
    this.params,
    required this.headers,
    this.credentials,
  });

  final String url;
  final HttpMethod method;
  final Body? body;
  final String? params;
  final Map<String, String> headers;
  final Credentials? credentials;

  String get fullUrl {
    if (params?.isEmpty ?? true) {
      return url;
    } else {
      if (url.contains('?')) {
        return "$url&$params";
      } else {
        return "$url?$params";
      }
    }
  }
}

class RequestBuilder {
  RequestBuilder(String url) : _url = url;

  final String _url;
  HttpMethod _method = HttpMethod.get;
  Body? _body;
  String? _params;
  final Map<String, String> _headers = {};
  Credentials? _credentials;

  RequestBuilder authorize(Credentials credentials) {
    _credentials = credentials;
    return this;
  }

  RequestBuilder body(Body body) {
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
    _params = serializeUrlEncoded(params);
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

  Request build() {
    return Request(
      url: _url,
      method: _method,
      body: _body,
      params: _params,
      headers: _headers,
      credentials: _credentials,
    );
  }
}
