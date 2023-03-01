import "dart:async";
import "dart:io";

import "package:cancellation/cancellation.dart";

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
  Future<ContentType?> download(
    Request request,
    Sink<List<int>> Function(HttpClientResponse) sinkFactory, {
    CopyStreamListener? listener,
    CopyStreamListener? uploadListener,
    CancellationToken cancellationToken = CancellationToken.neverCancel,
  }) async {
    final response = await _makeConnection(
      request,
      cancellationToken,
      uploadListener,
    );
    assert(() {
      if (enableLog) {
        print("Status: ${response.statusCode}");
      }
      return true;
    }());
    cancellationToken.throwIfCancelled();
    if (response.statusCode != 200) {
      final body = await response.readAll().asCancellable(cancellationToken);
      final bodyString = response.getContentEncoding().decode(body);
      assert(() {
        if (enableLog) {
          print("Response: $bodyString");
        }
        return true;
      }());
      throw HttpStatusException(response.statusCode, bodyString);
    }
    final contentType = response.headers.contentType;
    final length = response.contentLength;
    final completer = Completer<ContentType?>();
    final sink = sinkFactory(response);
    final subscriptionRef = _Ref<StreamSubscription<void>>();
    var count = 0;

    subscriptionRef.value = response.listen(
      (data) {
        if (cancellationToken.isCancelled) {
          subscriptionRef.value.cancel();
          sink.close();
          completer.completeError(const CancellationException());
        } else {
          count += data.length;
          sink.add(data);
          listener?.call(count, length, false);
        }
      },
      onDone: () {
        listener?.call(count, length, true);
        sink.close();
        completer.complete(contentType);
      },
      // ignore: avoid_types_on_closure_parameters
      onError: (Object e) {
        sink.close();
        completer.completeError(e);
      },
      cancelOnError: true,
    );

    return completer.future;
  }

  Future<HttpClientResponse> _makeConnection(
    Request request,
    CancellationToken cancellationToken,
    CopyStreamListener? listener,
  ) async {
    final uri = Uri.parse(request.fullUrl);
    final client = HttpClient();

    final HttpClientRequest httpRequest;
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
    }

    cancellationToken.throwIfCancelled();

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
    await _writeContent(httpRequest, request, cancellationToken, listener);
    cancellationToken.throwIfCancelled();

    final response = await httpRequest.close();
    cancellationToken.throwIfCancelled();

    if (!identical(request.responseHeaders, const <String, String>{})) {
      request.responseHeaders.clear();
      response.headers.forEach((name, values) {
        request.responseHeaders[name] = values.last;
      });
    }
    return response;
  }

  Future<void> _writeContent(
    HttpClientRequest request,
    Request builder,
    CancellationToken cancellationToken,
    CopyStreamListener? listener,
  ) {
    final body = builder.body;
    if (body == null) {
      return Future.value();
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
      return content.copyTo(request, listener, body.length, cancellationToken);
    }
  }
}

class _Ref<T> {
  late T value;
}
