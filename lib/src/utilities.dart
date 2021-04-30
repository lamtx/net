import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';

import 'cancellation_exception.dart';
import 'copy_stream_listener.dart';

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

  Future<void> copyTo(IOSink destination,
      [CopyStreamListener? listener, int? estimatedLength]) async {
    var current = 0;
    final total = estimatedLength ?? -1;
    final queue = StreamQueue(this);
    while (await queue.hasNext) {
      final data = await queue.next;
      destination.add(data);
      await destination.flush();
      current += data.length;
      if (listener?.call(current, total, false) ?? false) {
        throw const CancellationException();
      }
    }

    listener?.call(current, total, true);
  }
}

String describeEnum(Object any) {
  final s = any.toString();
  final index = s.indexOf(".");
  return index == -1 ? s : s.substring(index + 1);
}

String toUrlEncoded(Map params) {
  final s = StringBuffer();
  params.forEach((dynamic key, dynamic value) {
    if (key is! String) {
      throw UnsupportedError("key must be a string");
    }
    if (value == null) {
      return;
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
