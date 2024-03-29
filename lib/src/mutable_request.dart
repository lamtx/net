import 'body.dart';
import 'credentials.dart';
import 'http_method.dart';
import 'request.dart';
import 'request_options.dart';

final class MutableRequest implements Request {
  MutableRequest({
    required this.url,
    this.method = HttpMethod.get,
    this.credentials,
    this.body,
    this.params = const {},
    this.headers = const {},
    this.options = const RequestOptions(),
  });

  MutableRequest.get({
    required this.url,
    this.credentials,
    this.body,
    this.params = const {},
    this.headers = const {},
    this.options = const RequestOptions(),
  }) : method = HttpMethod.get;

  MutableRequest.post({
    required this.url,
    this.credentials,
    this.body,
    this.params = const {},
    this.headers = const {},
    this.options = const RequestOptions(),
  }) : method = HttpMethod.post;

  MutableRequest.put({
    required this.url,
    this.credentials,
    this.body,
    this.params = const {},
    this.headers = const {},
    this.options = const RequestOptions(),
  }) : method = HttpMethod.put;

  MutableRequest.patch({
    required this.url,
    this.credentials,
    this.body,
    this.params = const {},
    this.headers = const {},
    this.options = const RequestOptions(),
  }) : method = HttpMethod.patch;

  MutableRequest.head({
    required this.url,
    this.credentials,
    this.body,
    this.params = const {},
    this.headers = const {},
    this.options = const RequestOptions(),
  }) : method = HttpMethod.head;

  MutableRequest.delete({
    required this.url,
    this.credentials,
    this.body,
    this.params = const {},
    this.headers = const {},
    this.options = const RequestOptions(),
  }) : method = HttpMethod.delete;

  @override
  final String url;
  @override
  HttpMethod method;
  @override
  Credentials? credentials;
  @override
  Body? body;
  @override
  Map<String, Object?> params;
  @override
  Map<String, String> headers;
  @override
  RequestOptions options;
}
