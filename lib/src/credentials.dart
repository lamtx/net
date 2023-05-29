import 'dart:io';

abstract interface class Credentials {
  void handleRequest(HttpHeaders headers);
}
