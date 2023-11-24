import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cancellation/cancellation.dart';

import "copy_stream_listener.dart";
import "data_parser.dart";
import 'debug.dart';
import 'http_headers_response.dart';
import 'request.dart';
import 'response_data.dart';
import 'utilities.dart';

abstract interface class Repository {
  Future<ContentType?> download(
    Request request,
    Sink<List<int>> Function(HttpClientResponse) sinkFactory, {
    CopyStreamListener? listener,
    CopyStreamListener? uploadListener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  });
}

class _ByteSink implements Sink<List<int>> {
  final _builder = BytesBuilder();

  @override
  void add(List<int> data) {
    _builder.add(data);
  }

  @override
  void close() {}

  Uint8List takeBytes() {
    return _builder.takeBytes();
  }
}

extension RepositoryExt on Repository {
  Future<ResponseData> getData(
    Request request, {
    HttpHeadersResponse? response,
    CopyStreamListener? uploadListener,
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) async {
    final byteSink = _ByteSink();
    try {
      final contentType = await download(
        request,
        (connection) {
          response?.set(connection);
          return byteSink;
        },
        uploadListener: uploadListener,
        listener: listener,
        cancellationToken: cancellationToken,
      );
      cancellationToken.throwIfCancelled();
      return ResponseData(byteSink.takeBytes(), contentType);
    } finally {
      byteSink.close();
    }
  }

  Future<String> getString(
    Request request, {
    HttpHeadersResponse? response,
    CopyStreamListener? uploadListener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) async {
    final body = await getData(
      request,
      response: response,
      uploadListener: uploadListener,
      cancellationToken: cancellationToken,
    );
    cancellationToken.throwIfCancelled();
    final bodyString = body.getContentEncoding().decode(body.data);

    assert(() {
      if (enableLog && request.options.isLogEnabled) {
        print("Response: $bodyString");
      }
      return true;
    }());

    return bodyString;
  }

  Future<T> get<T>(
    Request request,
    DataParser<T> parser, {
    HttpHeadersResponse? response,
    CopyStreamListener? uploadListener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) async {
    final s = await getString(
      request,
      uploadListener: uploadListener,
      response: response,
      cancellationToken: cancellationToken,
    );
    cancellationToken.throwIfCancelled();
    if (s.isEmpty) {
      throw StateError("empty response");
    }
    return parser.parseObject(s);
  }

  Future<List<T>> getList<T>(
    Request request,
    DataParser<T> parser, {
    HttpHeadersResponse? response,
    CopyStreamListener? uploadListener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) async {
    final s = await getString(
      request,
      response: response,
      uploadListener: uploadListener,
      cancellationToken: cancellationToken,
    );
    cancellationToken.throwIfCancelled();
    if (s.isEmpty) {
      return <T>[];
    }
    return parser.parseList(s);
  }

  Future<List<String>> getStringList(
    Request request, {
    HttpHeadersResponse? response,
    CopyStreamListener? uploadListener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) async {
    final s = await getString(
      request,
      uploadListener: uploadListener,
      response: response,
      cancellationToken: cancellationToken,
    );
    cancellationToken.throwIfCancelled();
    if (s.isEmpty) {
      return const [];
    }
    final dynamic array = json.decode(s);
    if (array is List) {
      return array.map((e) => e.toString()).toList();
    } else {
      throw Exception("The provided json is not a list.");
    }
  }

  Future<void> saveToFile(
    Request request,
    File file, {
    HttpHeadersResponse? response,
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) {
    return download(
      request,
      (connection) {
        response?.set(connection);
        return file.openWrite(mode: FileMode.writeOnly);
      },
      listener: listener,
      cancellationToken: cancellationToken,
    );
  }

  Future<File> saveToDirectory(
    Request request,
    Directory directory, {
    HttpHeadersResponse? response,
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) async {
    late final File file;
    await download(
      request,
      (connection) {
        response?.set(connection);
        final fileName = connection.headers
                .value("content-disposition")
                ?.extractFileName() ??
            "unknown";
        file = File("${directory.path}/$fileName");
        return file.openWrite(mode: FileMode.writeOnly);
      },
      listener: listener,
      cancellationToken: cancellationToken,
    );
    cancellationToken.throwIfCancelled();
    return file;
  }
}

extension on String {
  String? extractFileName() {
    const start = 'filename="';
    final index = indexOf(start);
    if (index != -1) {
      final endIndex = indexOf('"', index + start.length);
      if (endIndex != -1) {
        return substring(index + start.length, endIndex);
      }
    }
    return null;
  }
}
