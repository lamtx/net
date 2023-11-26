final class RequestOptions {
  const RequestOptions({
    this.isLogEnabled = true,
    this.acceptedStatusCode = const {},
  });

  final bool isLogEnabled;

  /// 200 is always accepted.
  final Set<int> acceptedStatusCode;

  static const disableLog = RequestOptions(isLogEnabled: false);
}
