///
/// return true to cancel the request
///
typedef CopyStreamListener = bool? Function(
    int current, int total, bool finished);
