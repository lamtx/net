import 'dart:io';

import 'copy_stream_listener.dart';
import 'data_parser.dart';
import 'network_service.dart';
import 'repository.dart';
import 'request.dart';
import 'request_builder.dart';
import 'utilities.dart';

extension ServiceBuilderExt on RequestBuilder {
  Future<String> getString([CopyStreamListener? listener]) {
    return const NetworkService().getString(build(), listener);
  }

  Future<T> get<T>(DataParser<T> parser, [CopyStreamListener? listener]) {
    return const NetworkService().get(build(), parser, listener);
  }

  Future<List<T>> getList<T>(DataParser<T> parser,
      [CopyStreamListener? listener]) {
    return const NetworkService().getList(build(), parser, listener);
  }

  Future<void> download(
    Sink<List<int>> Function(HttpClientResponse) sinkFactory, [
    CopyStreamListener? listener,
  ]) {
    return const NetworkService().download(build(), sinkFactory, listener);
  }

  Future<void> saveToFile(File file, [CopyStreamListener? listener]) {
    return const NetworkService().saveToFile(build(), file, listener);
  }

  Future<File> saveToDirectory(Directory directory,
      [CopyStreamListener? listener]) async {
    return const NetworkService().saveToDirectory(build(), directory, listener);
  }
}

extension RequestExt on Request {
  String get fullUrl {
    if (params.isEmpty) {
      return url;
    } else {
      if (url.contains('?')) {
        return "$url&${toUrlEncoded(params)}";
      } else {
        return "$url?${toUrlEncoded(params)}";
      }
    }
  }

  Future<String> getString([CopyStreamListener? listener]) {
    return const NetworkService().getString(this, listener);
  }

  Future<T> get<T>(DataParser<T> parser, [CopyStreamListener? listener]) {
    return const NetworkService().get(this, parser, listener);
  }

  Future<List<T>> getList<T>(DataParser<T> parser,
      [CopyStreamListener? listener]) {
    return const NetworkService().getList(this, parser, listener);
  }

  Future<List<String>> getStringList([CopyStreamListener? listener]) {
    return const NetworkService().getStringList(this, listener);
  }

  Future<void> download(
    Sink<List<int>> Function(HttpClientResponse) sinkFactory, [
    CopyStreamListener? listener,
  ]) {
    return const NetworkService().download(this, sinkFactory, listener);
  }

  Future<void> saveToFile(File file, [CopyStreamListener? listener]) {
    return const NetworkService().saveToFile(this, file, listener);
  }

  Future<File> saveToDirectory(
    Directory directory, [
    CopyStreamListener? listener,
  ]) async {
    return const NetworkService().saveToDirectory(this, directory, listener);
  }
}
