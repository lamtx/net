import "dart:async";
import "dart:io";
import 'dart:typed_data';

import 'cancellation_exception.dart';
import "copy_stream_listener.dart";
import "debug.dart";
import 'http_method.dart';
import "http_status_exception.dart";
import "repository.dart";
import 'request.dart';
import 'request_ext.dart';
import "utilities.dart";

class NetworkService extends Repository {
  const NetworkService();

  @override
  Future<Uint8List> getData(Request request,
      [CopyStreamListener? listener]) async {
    final response = await _makeConnection(request, listener);
    final body = await response.readAll();

    assert(() {
      if (enableLog) {
        print("Status: ${response.statusCode}");
      }
      return true;
    }());

    if (response.statusCode == 200) {
      return body;
    } else {
      final bodyString = response.getContentEncoding().decode(body);
      assert(() {
        if (enableLog) {
          print("Response: $bodyString");
        }
        return true;
      }());
      throw HttpStatusException(response.statusCode, bodyString);
    }
  }

  @override
  Future<void> download(
    Request request,
    Sink<List<int>> Function(HttpClientResponse) sinkFactory, [
    CopyStreamListener? listener,
  ]) async {
    final response = await _makeConnection(request);
    assert(() {
      if (enableLog) {
        print("Status: ${response.statusCode}");
      }
      return true;
    }());
    if (response.statusCode != 200) {
      final body = await response.readAll();
      final bodyString = response.getContentEncoding().decode(body);
      assert(() {
        if (enableLog) {
          print("Response: $bodyString");
        }
        return true;
      }());
      throw HttpStatusException(response.statusCode, bodyString);
    }
    final length = response.contentLength;
    final completer = Completer<void>();
    final sink = sinkFactory(response);
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

  Future<HttpClientResponse> _makeConnection(Request request,
      [CopyStreamListener? listener]) async {
    final uri = Uri.parse(request.fullUrl);
    final client = HttpClient();

    HttpClientRequest httpRequest;
    switch (request.method) {
      case HttpMethod.get:
        httpRequest = await client.getUrl(uri);
        break;
      case HttpMethod.post:
        httpRequest = await client.postUrl(uri);
        break;
      case HttpMethod.patch:
        httpRequest = await client.patchUrl(uri);
        break;
      case HttpMethod.put:
        httpRequest = await client.putUrl(uri);
        break;
      case HttpMethod.head:
        httpRequest = await client.headUrl(uri);
        break;
      case HttpMethod.delete:
        httpRequest = await client.deleteUrl(uri);
        break;
      default:
        throw FallThroughError();
    }

    assert(() {
      if (enableLog) {
        print("${request.method.name.toUpperCase()}: $uri");
        print("Headers: ${request.headers}");
        print("Credentials: ${request.credentials}");
      }
      return true;
    }());

    request.headers.forEach((key, value) {
      httpRequest.headers.add(key, value);
    });
    request.credentials?.handleRequest(httpRequest.headers);
    await _writeContent(httpRequest, request, listener);
    final response = await httpRequest.close();

    if (!identical(request.responseHeaders, const <String, String>{})) {
      request.responseHeaders.clear();
      response.headers.forEach((name, values) {
        request.responseHeaders[name] = values.last;
      });
    }
    return response;
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
