import 'dart:io';

abstract class Body {
  ContentType get contentType;

  Stream<List<int>> get content;

  int get length;
}
