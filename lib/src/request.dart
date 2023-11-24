import '../net.dart';
import 'debug_config.dart';

abstract interface class Request {
  const factory Request({
    required String url,
    HttpMethod method,
    Credentials? credentials,
    Map<String, Object?> params,
    Map<String, String> headers,
    Body? body,
    DebugConfig debugConfig,
  }) = _ImmutableRequest;

  const factory Request.get({
    required String url,
    Credentials? credentials,
    Map<String, Object?> params,
    Map<String, String> headers,
    Body? body,
    DebugConfig debugConfig,
  }) = _ImmutableRequest.get;

  const factory Request.post({
    required String url,
    Credentials? credentials,
    Map<String, Object?> params,
    Map<String, String> headers,
    Body? body,
    DebugConfig debugConfig,
  }) = _ImmutableRequest.post;

  const factory Request.patch({
    required String url,
    Credentials? credentials,
    Map<String, Object?> params,
    Map<String, String> headers,
    Body? body,
    DebugConfig debugConfig,
  }) = _ImmutableRequest.patch;

  const factory Request.delete({
    required String url,
    Credentials? credentials,
    Map<String, Object?> params,
    Map<String, String> headers,
    Body? body,
    DebugConfig debugConfig,
  }) = _ImmutableRequest.delete;

  const factory Request.head({
    required String url,
    Credentials? credentials,
    Map<String, Object?> params,
    Map<String, String> headers,
    Body? body,
    DebugConfig debugConfig,
  }) = _ImmutableRequest.head;

  const factory Request.put({
    required String url,
    Credentials? credentials,
    Map<String, Object?> params,
    Map<String, String> headers,
    Body? body,
    DebugConfig debugConfig,
  }) = _ImmutableRequest.put;

  String get url;

  HttpMethod get method;

  Body? get body;

  Map<String, Object?> get params;

  Map<String, String> get headers;

  Credentials? get credentials;

  DebugConfig get debugConfig;
}

final class _ImmutableRequest implements Request {
  const _ImmutableRequest({
    required this.url,
    this.method = HttpMethod.get,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.debugConfig = const DebugConfig(),
  });

  const _ImmutableRequest.get({
    required this.url,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.debugConfig = const DebugConfig(),
  }) : method = HttpMethod.get;

  const _ImmutableRequest.post({
    required this.url,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.debugConfig = const DebugConfig(),
  }) : method = HttpMethod.post;

  const _ImmutableRequest.patch({
    required this.url,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.debugConfig = const DebugConfig(),
  }) : method = HttpMethod.patch;

  const _ImmutableRequest.delete({
    required this.url,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.debugConfig = const DebugConfig(),
  }) : method = HttpMethod.delete;

  const _ImmutableRequest.head({
    required this.url,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.debugConfig = const DebugConfig(),
  }) : method = HttpMethod.head;

  const _ImmutableRequest.put({
    required this.url,
    this.credentials,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.debugConfig = const DebugConfig(),
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
  final DebugConfig debugConfig;
}
