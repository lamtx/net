import "dart:async";

import "copy_stream_listener.dart";
import "repository.dart";
import "service_builder.dart";

class MultipleRepository extends Repository {
  MultipleRepository(List<Repository> repositories)
      : _repositories = repositories;

  final List<Repository> _repositories;

  @override
  Future<String> getString(Request builder, [CopyStreamListener listener]) async {
    for (final value in _repositories) {
      final response = await value.getString(builder);
      if (response != null) {
        return response;
      }
    }
    return null;
  }
}
