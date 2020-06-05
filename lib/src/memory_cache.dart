import "copy_stream_listener.dart";
import "repository.dart";
import "service_builder.dart";

class MemoryCache extends Repository {
  MemoryCache(this.base);

  final Repository base;

  final Map<String, String> _cache = {};

  @override
  Future<String> getString(Request builder, [CopyStreamListener listener]) async {
    final key = builder.fullUrl;
    if (_cache.containsKey(key)) {
      return _cache[key];
    } else {
      final response = await base.getString(builder);
      _cache[key] = response;
      return response;
    }
  }
}
