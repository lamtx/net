import '../net.dart';

/// Allows to extends and implements
class Request {
  const Request({
    required this.url,
    this.method = HttpMethod.get,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.responseHeaders = const {},
  });

  const Request.get({
    required this.url,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.responseHeaders = const {},
  }) : method = HttpMethod.get;

  const Request.post({
    required this.url,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.responseHeaders = const {},
  }) : method = HttpMethod.post;

  const Request.patch({
    required this.url,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.responseHeaders = const {},
  }) : method = HttpMethod.patch;

  const Request.delete({
    required this.url,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.responseHeaders = const {},
  }) : method = HttpMethod.delete;

  const Request.head({
    required this.url,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.responseHeaders = const {},
  }) : method = HttpMethod.head;

  const Request.put({
    required this.url,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.responseHeaders = const {},
  }) : method = HttpMethod.put;

  final String url;
  final HttpMethod method;
  final Body? body;
  final Map<String, Object?> params;
  final Map<String, String> headers;
  final Map<String, String> responseHeaders;
  final Credentials? credentials;
}
