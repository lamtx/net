import 'dart:io';

import 'copy_stream_listener.dart';
import 'data_parser.dart';
import 'network_service.dart';
import 'repository.dart';
import 'request.dart';
import 'service_builder.dart';

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

  Future<void> download(File file, [CopyStreamListener? listener]) {
    return const NetworkService().download(build(), file, listener);
  }
}

extension RequestExt on Request {
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

  Future<void> download(File file, [CopyStreamListener? listener]) {
    return const NetworkService().download(this, file, listener);
  }
}
