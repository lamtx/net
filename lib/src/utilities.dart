import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:cancellation/cancellation.dart';

import '../net.dart';

extension StreamExt on Stream<List<int>> {
  Future<Uint8List> readAll() {
    final completer = Completer<Uint8List>();
    final writer = BytesBuilder();
    listen(
      writer.add,
      onError: completer.completeError,
      onDone: () {
        completer.complete(writer.takeBytes());
      },
      cancelOnError: true,
    );
    return completer.future;
  }

  Future<void> copyTo(
    IOSink destination, [
    CopyStreamListener? listener,
    int? estimatedLength,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  ]) async {
    var current = 0;
    final total = estimatedLength ?? -1;
    final queue = StreamQueue(this);
    while (await queue.hasNext) {
      cancellationToken.throwIfCancelled();
      final data = await queue.next;
      cancellationToken.throwIfCancelled();
      destination.add(data);

      await destination.flush();
      cancellationToken.throwIfCancelled();
      current += data.length;
      listener?.call(current, total, false);
    }
    listener?.call(current, total, true);
  }
}

String toUrlEncoded(Map<String, Object?> params) {
  final s = StringBuffer();
  params.forEach((key, value) {
    if (value == null) {
      return;
    }
    if (value is ToJson) {
      value = value.toJson();
    } else if (value is JsonObject) {
      value = value.toJson();
    }
    String sValue;
    if (value is String) {
      if (value.isEmpty) {
        return;
      }
      sValue = value;
    } else if (value is num) {
      sValue = value.toString();
    } else if (value is bool) {
      sValue = value.toString();
    } else if (value is DateTime) {
      sValue = value.toUtc().toIso8601String();
    } else if (value is Enum) {
      sValue = value.index.toString();
    } else {
      throw UnsupportedError("Unsupported parameter type ${value.runtimeType}");
    }

    if (s.isNotEmpty) {
      s.write("&");
    }
    s
      ..write(Uri.encodeComponent(key))
      ..write("=")
      ..write(Uri.encodeComponent(sValue));
  });
  return s.toString();
}

extension HttpClientResponseEncoding on HttpClientResponse {
  Encoding getContentEncoding() {
    final charset = headers.contentType?.charset;
    if (charset == null) {
      return utf8;
    }
    return Encoding.getByName(charset) ??
        (throw Exception("Unknown charset $charset."));
  }
}

extension ResponseDataEncoding on ResponseData {
  Encoding getContentEncoding() {
    final charset = contentType?.charset;
    if (charset == null) {
      return utf8;
    }
    return Encoding.getByName(charset) ??
        (throw Exception("Unknown charset $charset."));
  }
}
