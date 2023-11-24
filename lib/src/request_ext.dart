import 'dart:io';

import 'package:cancellation/cancellation.dart';

import 'copy_stream_listener.dart';
import 'data_parser.dart';
import 'http_headers_response.dart';
import 'network_service.dart';
import 'repository.dart';
import 'request.dart';
import 'request_builder.dart';
import 'utilities.dart';

extension ServiceBuilderExt on RequestBuilder {
  Future<String> getString({
    HttpHeadersResponse? response,
    CopyStreamListener? uploadListener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) {
    return const NetworkService().getString(
      build(),
      uploadListener: uploadListener,
      response: response,
      cancellationToken: cancellationToken,
    );
  }

  Future<T> get<T>(
    DataParser<T> parser, {
    HttpHeadersResponse? response,
    CopyStreamListener? uploadListener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) {
    return const NetworkService().get(
      build(),
      parser,
      response: response,
      uploadListener: uploadListener,
      cancellationToken: cancellationToken,
    );
  }

  Future<List<T>> getList<T>(
    DataParser<T> parser, {
    HttpHeadersResponse? response,
    CopyStreamListener? uploadListener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) {
    return const NetworkService().getList(
      build(),
      parser,
      response: response,
      uploadListener: uploadListener,
      cancellationToken: cancellationToken,
    );
  }

  Future<void> download(
    Sink<List<int>> Function(HttpClientResponse) sinkFactory, {
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) {
    return const NetworkService().download(
      build(),
      sinkFactory,
      listener: listener,
      cancellationToken: cancellationToken,
    );
  }

  Future<void> saveToFile(
    File file, {
    HttpHeadersResponse? response,
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) {
    return const NetworkService().saveToFile(
      build(),
      file,
      response: response,
      listener: listener,
      cancellationToken: cancellationToken,
    );
  }

  Future<File> saveToDirectory(
    Directory directory, {
    HttpHeadersResponse? response,
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) async {
    return const NetworkService().saveToDirectory(
      build(),
      directory,
      response: response,
      listener: listener,
      cancellationToken: cancellationToken,
    );
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

  Future<String> getString({
    HttpHeadersResponse? response,
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) {
    return const NetworkService().getString(
      this,
      uploadListener: listener,
      cancellationToken: cancellationToken,
    );
  }

  Future<T> get<T>(
    DataParser<T> parser, {
    HttpHeadersResponse? response,
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) {
    return const NetworkService().get(
      this,
      parser,
      uploadListener: listener,
      cancellationToken: cancellationToken,
    );
  }

  Future<List<T>> getList<T>(
    DataParser<T> parser, {
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) {
    return const NetworkService().getList(
      this,
      parser,
      uploadListener: listener,
      cancellationToken: cancellationToken,
    );
  }

  Future<List<String>> getStringList({
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) {
    return const NetworkService().getStringList(
      this,
      uploadListener: listener,
      cancellationToken: cancellationToken,
    );
  }

  Future<void> download(
    Sink<List<int>> Function(HttpClientResponse) sinkFactory, {
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) {
    return const NetworkService().download(
      this,
      sinkFactory,
      listener: listener,
      cancellationToken: cancellationToken,
    );
  }

  Future<void> saveToFile(
    File file, {
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) {
    return const NetworkService().saveToFile(
      this,
      file,
      listener: listener,
      cancellationToken: cancellationToken,
    );
  }

  Future<File> saveToDirectory(
    Directory directory, {
    CopyStreamListener? listener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) async {
    return const NetworkService().saveToDirectory(
      this,
      directory,
      listener: listener,
      cancellationToken: cancellationToken,
    );
  }
}
