import 'dart:async';

import 'package:ginilog_customer_app/core/utils/package_export.dart';

enum ConnectivityStatus { notDetermined, isConnected, isDisconnected }

final connectivityStatusProviders =
    AsyncNotifierProvider<ConnectivityNotifier, ConnectivityStatus>(
      ConnectivityNotifier.new,
    );

class ConnectivityNotifier extends AsyncNotifier<ConnectivityStatus> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  FutureOr<ConnectivityStatus> build() async {
    ref.onDispose(() {
      _subscription?.cancel();
    });

    // ✅ Now returns List<ConnectivityResult>
    final results = await Connectivity().checkConnectivity();

    final hasConnection = results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn,
    );

    final initialStatus =
        hasConnection
            ? ConnectivityStatus.isConnected
            : ConnectivityStatus.isDisconnected;

    // ✅ Start listening AFTER initial value
    _listenToConnectivity();

    return initialStatus;
  }

  void _listenToConnectivity() {
    _subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final hasConnection = results.any(
        (result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet ||
            result == ConnectivityResult.vpn,
      );

      final newStatus =
          hasConnection
              ? ConnectivityStatus.isConnected
              : ConnectivityStatus.isDisconnected;

      // Only update if changed
      if (state.value != newStatus) {
        state = AsyncData(newStatus);
      }
    });
  }
}
