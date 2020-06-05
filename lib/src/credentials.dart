import 'dart:io';

abstract class Credentials {
  void handleRequest(HttpHeaders headers);
}
