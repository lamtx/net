import 'body.dart';
import 'credentials.dart';
import 'http_method.dart';
import 'request_options.dart';

abstract interface class Request {
  const factory Request({
    required String url,
    HttpMethod method,
    Credentials? credentials,
    Map<String, Object?> params,
    Map<String, String> headers,
    Body? body,
    RequestOptions options,
  }) = _ImmutableRequest;

  const factory Request.get({
    required String url,
    Credentials? credentials,
    Map<String, Object?> params,
    Map<String, String> headers,
    Body? body,
    RequestOptions options,
  }) = _ImmutableRequest.get;

  const factory Request.post({
    required String url,
    Credentials? credentials,
    Map<String, Object?> params,
    Map<String, String> headers,
    Body? body,
    RequestOptions options,
  }) = _ImmutableRequest.post;

  const factory Request.patch({
    required String url,
    Credentials? credentials,
    Map<String, Object?> params,
    Map<String, String> headers,
    Body? body,
    RequestOptions options,
  }) = _ImmutableRequest.patch;

  const factory Request.delete({
    required String url,
    Credentials? credentials,
    Map<String, Object?> params,
    Map<String, String> headers,
    Body? body,
    RequestOptions options,
  }) = _ImmutableRequest.delete;

  const factory Request.head({
    required String url,
    Credentials? credentials,
    Map<String, Object?> params,
    Map<String, String> headers,
    Body? body,
    RequestOptions options,
  }) = _ImmutableRequest.head;

  const factory Request.put({
    required String url,
    Credentials? credentials,
    Map<String, Object?> params,
    Map<String, String> headers,
    Body? body,
    RequestOptions options,
  }) = _ImmutableRequest.put;

  String get url;

  HttpMethod get method;

  Body? get body;

  Map<String, Object?> get params;

  Map<String, String> get headers;

  Credentials? get credentials;

  RequestOptions get options;
}

final class _ImmutableRequest implements Request {
  const _ImmutableRequest({
    required this.url,
    this.method = HttpMethod.get,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.options = const RequestOptions(),
  });

  const _ImmutableRequest.get({
    required this.url,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.options = const RequestOptions(),
  }) : method = HttpMethod.get;

  const _ImmutableRequest.post({
    required this.url,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.options = const RequestOptions(),
  }) : method = HttpMethod.post;

  const _ImmutableRequest.patch({
    required this.url,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.options = const RequestOptions(),
  }) : method = HttpMethod.patch;

  const _ImmutableRequest.delete({
    required this.url,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.options = const RequestOptions(),
  }) : method = HttpMethod.delete;

  const _ImmutableRequest.head({
    required this.url,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.options = const RequestOptions(),
  }) : method = HttpMethod.head;

  const _ImmutableRequest.put({
    required this.url,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.options = const RequestOptions(),
  }) : method = HttpMethod.put;

  @override
  final String url;
  @override
  final HttpMethod method;
  @override
  final Body? body;
  @override
  final Map<String, Object?> params;
  @override
  final Map<String, String> headers;
  @override
  final Credentials? credentials;
  @override
  final RequestOptions options;
}
