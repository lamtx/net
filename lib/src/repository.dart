import 'dart:convert';
import 'dart:typed_data';

import "copy_stream_listener.dart";
import "data_parser.dart";
import 'debug.dart';
import 'request.dart';

abstract class Repository {
  const Repository();

  Future<Uint8List> getData(Request request, [CopyStreamListener? listener]);
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
}
