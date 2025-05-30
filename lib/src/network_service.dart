import 'package:http/http.dart';

abstract final class NetworkService {
  static Client? _client;

  static Client getClient() {
    _client ??= Client();
    return _client!;
  }
}
