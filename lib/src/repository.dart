import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cancellation/cancellation.dart';

import "copy_stream_listener.dart";
import "data_parser.dart";
import 'debug.dart';
import 'request.dart';
import 'response_data.dart';
import 'utilities.dart';

abstract class Repository {
  const Repository();

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
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) async {
    final byteSink = _ByteSink();
    final contentType = await download(
      request,
      (_) => byteSink,
      uploadListener: listener,
      cancellationToken: cancellationToken,
    );
    cancellationToken.throwIfCancelled();
    return ResponseData(byteSink.takeBytes(), contentType);
  }

  Future<String> getString(
    Request request, {
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) async {
    final body = await getData(
      request,
      listener: listener,
      cancellationToken: cancellationToken,
    );
    cancellationToken.throwIfCancelled();
    final bodyString = body.getContentEncoding().decode(body.data);

    assert(() {
      if (enableLog) {
        print("Response: $bodyString");
      }
      return true;
    }());

    return bodyString;
  }

  Future<T> get<T>(
    Request request,
    DataParser<T> parser, {
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) async {
    final response = await getString(
      request,
      listener: listener,
      cancellationToken: cancellationToken,
    );
    cancellationToken.throwIfCancelled();
    if (response.isEmpty) {
      throw StateError("empty response");
    }
    return parser.parseObject(response);
  }

  Future<List<T>> getList<T>(
    Request request,
    DataParser<T> parser, {
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) async {
    final response = await getString(
      request,
      listener: listener,
      cancellationToken: cancellationToken,
    );
    cancellationToken.throwIfCancelled();
    if (response.isEmpty) {
      return <T>[];
    }
    return parser.parseList(response);
  }

  Future<List<String>> getStringList(
    Request request, {
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) async {
    final response = await getString(
      request,
      listener: listener,
      cancellationToken: cancellationToken,
    );
    cancellationToken.throwIfCancelled();
    if (response.isEmpty) {
      return const [];
    }
    final dynamic array = json.decode(response);
    if (array is List) {
      return array.map((dynamic e) => e.toString()).toList();
    } else {
      throw Exception("The provided json is not a list.");
    }
  }

  Future<void> saveToFile(
    Request request,
    File file, {
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) {
    return download(
      request,
      (_) => file.openWrite(mode: FileMode.writeOnly),
      listener: listener,
      cancellationToken: cancellationToken,
    );
  }

  Future<File> saveToDirectory(
    Request request,
    Directory directory, {
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) async {
    late final File file;
    await download(
      request,
      (response) {
        final fileName =
            response.headers.value("content-disposition")?.extractFileName() ??
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
    const start = "filename=\"";
    final index = indexOf(start);
    if (index != -1) {
      final endIndex = indexOf("\"", index + start.length);
      if (endIndex != -1) {
        return substring(index + start.length, endIndex);
      }
    }
    return null;
  }
}
