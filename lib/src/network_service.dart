import "dart:async";
import 'dart:convert';
import "dart:io";
import 'dart:typed_data';

import 'cancellation_exception.dart';
import "copy_stream_listener.dart";
import "debug.dart";
import "http_status_exception.dart";
import "repository.dart";
import "service_builder.dart";
import "utilities.dart";

class NetworkService extends Repository {
  const NetworkService();

  @override
  Future<Uint8List> getData(Request builder,
      [CopyStreamListener? listener]) async {
    final response = await _makeConnection(builder, listener);
    final body = await response.readAll();

    assert(() {
      if (enableLog) {
        print("Status: ${response.statusCode}");
      }
      return true;
    }());
    if (200 <= response.statusCode && response.statusCode < 300) {
      return body;
    } else {
      final bodyString = utf8.decode(body);
      assert(() {
        if (enableLog) {
          print("Response: $bodyString");
        }
        return true;
      }());
      throw HttpStatusException(response.statusCode, bodyString);
    }
  }

  Future<void> download(Request builder, File file,
      [CopyStreamListener? listener]) async {
    final response = await _makeConnection(builder);
    final length = response.contentLength;
    final completer = Completer<void>();
    final sink = file.openWrite(mode: FileMode.writeOnly);
    final subscriptionRef = _Ref<StreamSubscription<void>>();
    var count = 0;

    subscriptionRef.value = response.listen((data) {
      count += data.length;
      sink.add(data);
      final stop = listener?.call(count, length, false) ?? false;
      if (stop) {
        subscriptionRef.value.cancel();
        sink.close();
        completer.completeError(const CancellationException());
      }
    }, onDone: () {
      listener?.call(count, length, true);
      sink.close();
      completer.complete();
    }, onError: (dynamic e) {
      sink.close();
      completer.completeError(e as Object);
    }, cancelOnError: true);

    return completer.future;
  }

  Future<HttpClientResponse> _makeConnection(Request builder,
      [CopyStreamListener? listener]) async {
    final uri = Uri.parse(builder.fullUrl);
    final client = HttpClient();

    HttpClientRequest request;
    switch (builder.method) {
      case HttpMethod.get:
        request = await client.getUrl(uri);
        break;
      case HttpMethod.post:
        request = await client.postUrl(uri);
        break;
      case HttpMethod.patch:
        request = await client.patchUrl(uri);
        break;
      case HttpMethod.put:
        request = await client.putUrl(uri);
        break;
      case HttpMethod.head:
        request = await client.headUrl(uri);
        break;
      case HttpMethod.delete:
        request = await client.deleteUrl(uri);
        break;
      default:
        throw FallThroughError();
    }

    assert(() {
      if (enableLog) {
        print("${describeEnum(builder.method).toUpperCase()}: $uri");
        print("Headers: ${builder.headers}");
        print("Credentials: ${builder.credentials}");
      }
      return true;
    }());

    builder.headers.forEach((key, value) {
      request.headers.add(key, value);
    });
    builder.credentials?.handleRequest(request.headers);
    await _writeContent(request, builder, listener);
    return request.close();
  }

  Future<void> _writeContent(HttpClientRequest request, Request builder,
      CopyStreamListener? listener) async {
    final body = builder.body;
    if (body == null) {
      return;
    }
    request.headers.contentType = body.contentType;

    final content = body.content;
    final contentLength = body.length;
    assert(() {
      print("Body: $body");
      return true;
    }());
    if (contentLength > 0) {
      request.headers.contentLength = contentLength;
    }
    if (listener == null) {
      return request.addStream(content);
    } else {
      return content.copyTo(request, listener, body.length);
    }
  }
}

class _Ref<T> {
  late T value;
}
