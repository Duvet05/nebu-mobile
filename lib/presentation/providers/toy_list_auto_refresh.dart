import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'toy_provider.dart';

/// Keeps the shared toy list fresh while the host screen is on stage:
/// re-syncs on a fixed interval and whenever the app returns to the
/// foreground. Tab screens are recreated on every tab switch, so the timer
/// only ever runs for the visible tab.
mixin ToyListAutoRefresh<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  static const _refreshInterval = Duration(seconds: 30);

  Timer? _toyRefreshTimer;
  AppLifecycleListener? _toyLifecycleListener;

  void startToyAutoRefresh() {
    _toyRefreshTimer ??= Timer.periodic(
      _refreshInterval,
      (_) => ref.read(toyProvider.notifier).syncMyToys(),
    );
    _toyLifecycleListener ??= AppLifecycleListener(
      onResume: () => ref.read(toyProvider.notifier).syncMyToys(),
    );
  }

  @override
  void dispose() {
    _toyRefreshTimer?.cancel();
    _toyLifecycleListener?.dispose();
    super.dispose();
  }
}
