import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';

import 'copy_stream_listener.dart';

extension StreamExt on Stream<List<int>> {
  Future<List<int>> readAll() {
    final completer = Completer<List<int>>();
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
      [CopyStreamListener listener, int estimatedLength]) async {
    var current = 0;
    final total = estimatedLength ?? -1;
    final queue = StreamQueue(this);
    while (await queue.hasNext) {
      final data = await queue.next;
      destination.add(data);
      await destination.flush();
      current += data.length;
      final stop = listener?.call(current, total, false) ?? false;
      if (stop) {
        break;
      }
    }

    listener?.call(current, total, true);
  }
}
