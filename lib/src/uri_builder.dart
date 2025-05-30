import 'package:ext/ext.dart';
import 'package:http/http.dart';
import 'package:net/src/request_builder.dart';

import 'body.dart';
import 'credentials.dart';
import 'http_method.dart';
import 'internal.dart';
import 'network_service.dart';

final class UriBuilder {
  UriBuilder(
    this._base, {
    Map<String, Object?> params = const {},
  }) : _params = params;

  final String _base;
  Map<String, Object?> _params;

  UriBuilder params(Map<String, Object?> params) {
    if (_params.isEmpty) {
      _params = {};
    }
    _params.addAll(params);
    return this;
  }

  Uri build() {
    final uri = _params.isEmpty
        ? _base
        : _base.contains('?')
            ? "$_base&${MapToJson(_params).serializeAsUrlEncoded()}"
            : "$_base?${MapToJson(_params).serializeAsUrlEncoded()}";
    return Uri.parse(uri);
  }

  RequestBuilder buildRequest() {
    return RequestBuilder(build());
  }
}

extension UriBuilderExt on UriBuilder {
  RequestBuilder body(Body? body) {
    return buildRequest().body(body);
  }

  RequestBuilder jsonBody(Map<String, Object?> json) {
    return buildRequest().jsonBody(json);
  }

  RequestBuilder credentials(Credentials? credentials) {
    return buildRequest().credentials(credentials);
  }

  RequestBuilder headers(Map<String, String> headers) {
    return buildRequest().headers(headers);
  }

  /// Sent this request to [NetworkService] instance.
  Future<StreamedResponse> send({
    Client Function() client = NetworkService.getClient,
    String method = HttpMethod.get,
    Credentials? credentials,
  }) {
    final request = Request(method, build());
    assert(log("$method: ${request.url}"));
    return client().send(request);
  }

  Future<StreamedResponse> post({
    Client Function() client = NetworkService.getClient,
  }) =>
      send(method: HttpMethod.post);
}
