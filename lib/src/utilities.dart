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
