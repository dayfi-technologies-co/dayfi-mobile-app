import 'dart:async';

const Duration kScreenFetchTimeout = Duration(seconds: 20);

Future<T> withScreenFetchTimeout<T>(
  Future<T> future, {
  Duration timeout = kScreenFetchTimeout,
}) {
  return future.timeout(
    timeout,
    onTimeout: () {
      throw TimeoutException(
        'Request timed out. Check your connection and try again.',
      );
    },
  );
}
