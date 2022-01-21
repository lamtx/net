import 'body.dart';
import 'credentials.dart';
import 'http_method.dart';
import 'utilities.dart';

class Request {
  Request({
    required this.url,
    this.method = HttpMethod.get,
    this.credentials,
    this.params = "",
    this.headers = const {},
    this.body,
  });

  factory Request.get({
    required String url,
    Credentials? credentials,
    Map<String, Object?> params = const {},
    Map<String, String> headers = const {},
    Body? body,
  }) =>
      Request(
        url: url,
        credentials: credentials,
        params: stringParams(params),
        headers: headers,
        body: body,
      );

  factory Request.post({
    required String url,
    Credentials? credentials,
    Map<String, Object?> params = const {},
    Map<String, String> headers = const {},
    Body? body,
  }) =>
      Request(
        url: url,
        method: HttpMethod.post,
        credentials: credentials,
        params: stringParams(params),
        headers: headers,
        body: body,
      );

  final String url;
  final HttpMethod method;
  final Body? body;
  final String params;
  final Map<String, String> headers;
  final Credentials? credentials;

  String get fullUrl {
    if (params.isEmpty) {
      return url;
    } else {
      if (url.contains('?')) {
        return "$url&$params";
      } else {
        return "$url?$params";
      }
    }
  }
}

String stringParams(Map<String, Object?> params) {
  return toUrlEncoded(params);
}
