import 'dart:io';

import 'package:ext/ext.dart';
import 'package:http/http.dart';

import 'body.dart';
import 'credentials.dart';
import 'http_method.dart';
import 'network_service.dart';

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

  RequestBuilder jsonObjectBody(ToJson json) {
    return body(StringBody(json.serializeAsJson(), Body.json));
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

extension RequestBuilderExt on RequestBuilder {
  /// Sent this request to [NetworkService] instance.
  Future<StreamedResponse> send({
    Client Function() client = NetworkService.getClient,
    String method = HttpMethod.get,
  }) async {
    final BaseRequest request;
    switch (_body) {
      case null:
        request = Request(method, _uri);
      case StringBody(:final content, :final contentType):
        request = Request(method, _uri)
          ..body = content
          ..headers[HttpHeaders.contentTypeHeader] = contentType.mimeType;
      case FileBody(:final file):
        final streamedRequest = StreamedRequest(method, _uri)
          ..headers[HttpHeaders.contentTypeHeader] = ContentType.binary.mimeType
          ..contentLength = file.lengthSync();
        file.openRead().listen(
          streamedRequest.sink.add,
          onDone: () {
            streamedRequest.sink.close();
          },
          onError: (e) {
            streamedRequest.sink.addError(e);
          },
          cancelOnError: true,
        );
        request = streamedRequest;
      case MultipartBody(:final children, :final contentType):
        final multipartRequest = MultipartRequest(method, _uri)
          ..headers[HttpHeaders.contentTypeHeader] = contentType.mimeType;
        await _buildMultipartRequest(multipartRequest, children);

        request = multipartRequest;
    }
    request.headers.addAll(_headers);
    _credentials?.handleRequest(request.headers);
    assert(() {
      print("$method: $_uri");
      print("Headers: ${request.headers}");
      print("Body: $_body");
      return true;
    }());

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

Future<void> _buildMultipartRequest(
  MultipartRequest request,
  List<Part> children,
) async {
  for (final part in children) {
    final file = switch (part.body) {
      StringBody(:final content, :final contentType) =>
        MultipartFile.fromString(
          part.name,
          content,
          contentType: contentType,
        ),
      FileBody(:final file) =>
        await MultipartFile.fromPath(part.name, file.path),
      MultipartBody() =>
        throw UnimplementedError("Multipart cannot contain other multipart"),
    };
    request.files.add(file);
  }
}
