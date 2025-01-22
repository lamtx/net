import 'dart:convert';
import 'dart:io';

import 'package:ext/ext.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

abstract final class HttpMethod {
  static const get = "GET";
  static const head = "HEAD";
  static const post = "POST";
  static const delete = "DELETE";
  static const put = "PUT";
  static const patch = "PATCH";
}

sealed class Body {}

final class StringBody implements Body {
  const StringBody(this.content, this.contentType);

  factory StringBody.json(Map<String, Object?> json) {
    return StringBody(
      _MapToJson(json).serializeAsJson(),
      ContentType.json,
    );
  }

  final String content;
  final ContentType contentType;

  @override
  String toString() => content;
}

abstract interface class Credentials {
  void handleRequest(Map<String, String> headers);
}

base class HttpStatusException implements Exception {
  const HttpStatusException(this.statusCode, this.content);

  final int statusCode;
  final String content;

  @override
  String toString() => "HTTP status $statusCode: $content";

  bool get isOk => statusCode == HttpStatus.ok;

  bool get isUnauthorized => statusCode == HttpStatus.unauthorized;

  bool get isClientError => 400 <= statusCode && statusCode < 500;
}

abstract final class NetworkService {
  static Client? _client;

  static Client getClient() {
    _client ??= Client();
    return _client!;
  }
}

final class UriBuilder {
  UriBuilder(
    this._base, {
    Map<String, Object?> params = const {},
  }) : _params = params;

  final String _base;
  Map<String, Object?> _params;

  UriBuilder params(Map<String, Object?> params) {
    if (_params.isEmpty) {
      _params = {};
    }
    _params.addAll(params);
    return this;
  }

  Uri build() {
    final uri = _params.isEmpty
        ? _base
        : _base.contains('?')
            ? "$_base&${_MapToJson(_params).serializeAsUrlEncoded()}"
            : "$_base?${_MapToJson(_params).serializeAsUrlEncoded()}";
    return Uri.parse(uri);
  }

  RequestBuilder buildRequest() {
    return RequestBuilder(build());
  }
}

final class RequestBuilder {
  RequestBuilder(this._uri);

  final Uri _uri;
  Body? _body;
  Credentials? _credentials;
  Map<String, String> _headers = const {};

  RequestBuilder body(Body? body) {
    _body = body;
    return this;
  }

  RequestBuilder jsonBody(Map<String, Object?> json) {
    return body(StringBody.json(json));
  }

  RequestBuilder credentials(Credentials? credentials) {
    _credentials = credentials;
    return this;
  }

  RequestBuilder headers(Map<String, String> headers) {
    if (_headers.isEmpty) {
      _headers = {};
    }
    _headers.addAll(headers);
    return this;
  }
}

extension UriBuilderExt on UriBuilder {
  RequestBuilder body(Body? body) {
    return buildRequest().body(body);
  }

  RequestBuilder jsonBody(Map<String, Object?> json) {
    return buildRequest().jsonBody(json);
  }

  RequestBuilder credentials(Credentials? credentials) {
    return buildRequest().credentials(credentials);
  }

  RequestBuilder headers(Map<String, String> headers) {
    return buildRequest().headers(headers);
  }

  /// Sent this request to [NetworkService] instance.
  Future<StreamedResponse> send({
    Client Function() client = NetworkService.getClient,
    String method = HttpMethod.get,
    Credentials? credentials,
  }) {
    final request = Request(method, build());
    return client().send(request);
  }

  Future<StreamedResponse> post({
    Client Function() client = NetworkService.getClient,
  }) =>
      send(method: HttpMethod.post);
}

extension RequestBuilderExt on RequestBuilder {
  /// Sent this request to [NetworkService] instance.
  Future<StreamedResponse> send({
    Client Function() client = NetworkService.getClient,
    String method = HttpMethod.get,
  }) {
    final request = Request(method, _uri);
    request.headers.addAll(_headers);
    _credentials?.handleRequest(request.headers);
    assert(() {
      print("$method: $_uri");
      print("Headers: ${request.headers}");
      return true;
    }());
    if (_body case final body?) {
      assert(log("Body", body.toString()));
      switch (body) {
        case StringBody():
          request.body = body.content;
          request.headers[HttpHeaders.contentTypeHeader] =
              body.contentType.toString();
      }
    }
    return client().send(request);
  }

  Future<StreamedResponse> get({
    Client Function() client = NetworkService.getClient,
  }) =>
      send(client: client);

  Future<StreamedResponse> post({
    Client Function() client = NetworkService.getClient,
  }) =>
      send(client: client, method: HttpMethod.post);

  Future<StreamedResponse> patch({
    Client Function() client = NetworkService.getClient,
  }) =>
      send(client: client, method: HttpMethod.patch);

  Future<StreamedResponse> put({
    Client Function() client = NetworkService.getClient,
  }) =>
      send(client: client, method: HttpMethod.put);

  Future<StreamedResponse> head({
    Client Function() client = NetworkService.getClient,
  }) =>
      send(client: client, method: HttpMethod.head);

  Future<StreamedResponse> delete({
    Client Function() client = NetworkService.getClient,
  }) =>
      send(client: client, method: HttpMethod.delete);
}

extension BaseRequestExt on BaseRequest {
  /// Sent this request to [NetworkService] instance.
  Future<StreamedResponse> send({
    Client Function() client = NetworkService.getClient,
  }) {
    return client().send(this);
  }
}

extension FutureStreamedResponseExt on Future<StreamedResponse> {
  OkResponse statusOk([Set<int> acceptedStatus = const {200}]) {
    return OkResponse(this, acceptedStatus);
  }
}

final class OkResponse {
  const OkResponse(this._responseFuture, this._acceptedStatus);

  final Future<StreamedResponse> _responseFuture;
  final Set<int> _acceptedStatus;
}

extension OkResponseExt on OkResponse {
  Future<StreamedResponse> _responseOrThrows() async {
    final response = await _responseFuture;
    assert(log("Status", response.statusCode.toString()));
    if (_acceptedStatus.isEmpty ||
        _acceptedStatus.contains(response.statusCode)) {
      return response;
    } else {
      final body = (await Response.fromStream(response)).body;
      assert(log("Response", body));
      throw HttpStatusException(response.statusCode, body);
    }
  }

  Future<String> text({Encoding defaultCharset = utf8}) async {
    final response = await _responseOrThrows();
    final charset = response.contentType?.parameters["charset"];
    final encoding = charset != null
        ? (Encoding.getByName(charset) ??
            (throw Exception("Unknown charset $charset")))
        : defaultCharset;
    final body =
        encoding.decode((await Response.fromStream(response)).bodyBytes);
    assert(log("Response", body));
    return body;
  }

  Future<T> json<T>(JsonObjectFactory<T> fromJson) async {
    return fromJson.parseObject(await text());
  }

  Future<List<T>> jsonList<T>(JsonObjectFactory<T> fromJson) async {
    return fromJson.parseList(await text());
  }

  Future<File> saveToDirectory(Directory directory,
      [String? pathToGetFileName]) async {
    final response = await _responseOrThrows();
    final contentDisposition = response.contentDisposition;
    final fileName = contentDisposition?.parameters["filename"] ??
        (pathToGetFileName == null ? "file" : basename(pathToGetFileName));

    final file = File(join(directory.path, fileName));
    final sink = file.openWrite();
    try {
      await sink.addStream(response.stream);
    } finally {
      await sink.close();
    }
    return file;
  }

  Future<void> saveToFile(File file) async {
    final response = await _responseOrThrows();
    final sink = file.openWrite();
    try {
      await sink.addStream(response.stream);
    } finally {
      await sink.close();
    }
  }
}

class _MapToJson implements ToJson {
  _MapToJson(this._map);

  final Map<String, Object?> _map;

  @override
  Object? toJson() => _map;
}

extension ResponseExt on BaseResponse {
  MediaType? _tryParse(String? mediaType) {
    if (mediaType == null) {
      return null;
    }
    try {
      return MediaType.parse(mediaType);
    } on FormatException catch (_) {
      return null;
    }
  }

  MediaType? get contentType =>
      _tryParse(headers[HttpHeaders.contentTypeHeader]);

  MediaType? get contentDisposition =>
      _tryParse(headers[HttpHeaders.contentDisposition]);
}
