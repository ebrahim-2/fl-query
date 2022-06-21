import 'package:flutter/widgets.dart';

abstract class BaseOperation<Data, StatusType> extends ChangeNotifier {
  /// The number of times the query should refetch in the time of error
  /// before giving up
  final int retries;
  final Duration retryDelay;

  // got from global options
  @protected
  Duration cacheTime;

  // all properties
  Data? data;
  dynamic error;
  StatusType status;

  /// total count of how many times the query retried to get a successful
  /// result
  int retryAttempts = 0;
  DateTime updatedAt;

  @protected
  bool fetched = false;

  /// used for keeping track of query activity. If the are no mounts &
  /// the passed cached time is over than the query is removed from
  /// storage/cache
  Set<ValueKey<String>> _mounts = {};

  BaseOperation({
    required this.cacheTime,
    required this.retries,
    required this.retryDelay,
    required this.status,
    this.data,
  }) : updatedAt = DateTime.now();

  void mount(ValueKey<String> uKey) {
    _mounts.add(uKey);
  }

  void unmount(ValueKey<String> uKey) {
    if (_mounts.length == 1) {
      Future.delayed(cacheTime, () {
        _mounts.remove(uKey);
        // for letting know QueryBowl that this one's time has come for
        // getting crushed
        notifyListeners();
      });
    } else {
      _mounts.remove(uKey);
    }
  }

  Set<ValueKey<String>> get mounts => _mounts;

  bool get isSuccess;
  bool get isError;
  bool get isLoading;
  bool get isIdle;
  bool get isInactive => mounts.isEmpty;
  bool get hasData => isSuccess && data != null;
  bool get hasError => isError && error != null;
}
