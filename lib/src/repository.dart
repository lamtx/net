import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import "copy_stream_listener.dart";
import "data_parser.dart";
import 'debug.dart';
import 'request.dart';

abstract class Repository {
  const Repository();

  Future<Uint8List> getData(Request request, [CopyStreamListener? listener]);

  Future<void> download(
    Request request,
    Sink<List<int>> Function(HttpClientResponse) sinkFactory, [
    CopyStreamListener? listener,
  ]);
}

extension RepositoryExt on Repository {
  Future<String> getString(Request request,
      [CopyStreamListener? listener]) async {
    final body = await getData(request, listener);
    final bodyString = utf8.decode(body);

    assert(() {
      if (enableLog) {
        print("Response: $bodyString");
      }
      return true;
    }());

    return bodyString;
  }

  Future<T> get<T>(Request request, DataParser<T> parser,
      [CopyStreamListener? listener]) async {
    final response = await getString(request, listener);
    if (response.isEmpty) {
      throw StateError("empty response");
    }
    return parser.parseObject(response);
  }

  Future<List<T>> getList<T>(Request builder, DataParser<T> parser,
      [CopyStreamListener? listener]) async {
    final response = await getString(builder, listener);
    if (response.isEmpty) {
      return <T>[];
    }
    return parser.parseList(response);
  }

  Future<List<String>> getStringList(Request request,
      [CopyStreamListener? listener]) async {
    final response = await getString(request, listener);
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

  Future<void> saveToFile(Request request, File file,
      [CopyStreamListener? listener]) {
    return download(
      request,
      (_) => file.openWrite(mode: FileMode.writeOnly),
      listener,
    );
  }

  Future<File> saveToDirectory(Request request, Directory directory,
      [CopyStreamListener? listener]) async {
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
      listener,
    );
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
