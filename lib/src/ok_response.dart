import 'dart:convert';
import 'dart:io';

import 'package:ext/ext.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

import 'http_status_exception.dart';

final class OkResponse {
  const OkResponse(this._responseFuture, this._acceptedStatus);

  final Future<StreamedResponse> _responseFuture;
  final Set<int> _acceptedStatus;
}

extension FutureStreamedResponseExt on Future<StreamedResponse> {
  OkResponse statusOk([Set<int> acceptedStatus = const {200}]) {
    return OkResponse(this, acceptedStatus);
  }
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

  Future<Map<String, String>> headers() async {
    final response = await _responseOrThrows();
    return response.headers;
  }

  Future<String> text({Encoding defaultCharset = utf8}) async {
    final response = await _responseOrThrows();
    final charset = response.contentType?.charset;
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

  Future<File> saveToDirectory(Directory directory) async {
    final response = await _responseOrThrows();
    final contentDisposition = response.contentDisposition;
    final fileName = contentDisposition?.parameters["filename"] ??
        response.request?.url.pathSegments.lastOrNull ??
        "file";

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

extension MediaTypeExt on MediaType {
  String? get charset => parameters["charset"];
}
