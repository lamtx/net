import 'dart:convert';
import 'dart:typed_data';

import "copy_stream_listener.dart";
import "data_parser.dart";
import 'debug.dart';
import "service_builder.dart";

abstract class Repository {
  const Repository();

  Future<Uint8List> getData(Request builder, [CopyStreamListener? listener]);

  Future<String> getString(Request builder,
      [CopyStreamListener? listener]) async {
    final body = await getData(builder, listener);
    final bodyString = utf8.decode(body);

    assert(() {
      if (enableLog) {
        print("Response: $bodyString");
      }
      return true;
    }());

    return bodyString;
  }

  Future<T> get<T>(Request builder, DataParser<T> parser,
      [CopyStreamListener? listener]) async {
    final response = await getString(builder, listener);
    if (response.isEmpty) {
      throw StateError("empty response");
    }
    return parser.parseObject(response);
  }

  Future<List<T>> getList<T>(Request builder, DataParser<T> parser,
      [CopyStreamListener? listener]) async {
    final response = await getString(builder, listener);
    if (response.isEmpty) {
      return const [];
    }
    return parser.parseList(response);
  }
}
