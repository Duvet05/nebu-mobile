import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../data/models/toy.dart';
import '../theme/app_colors.dart';

extension ToyStatusUI on ToyStatus {
  Color color(BuildContext context) => switch (this) {
    ToyStatus.active || ToyStatus.connected => context.colors.success,
    ToyStatus.inactive => context.colors.grey400,
    ToyStatus.disconnected => context.colors.warning,
    ToyStatus.maintenance => context.colors.warning,
    ToyStatus.pending => context.colors.warning,
    ToyStatus.error => context.colors.error,
    ToyStatus.blocked => context.colors.error,
  };

  String label() => switch (this) {
    ToyStatus.active => 'toys.status_active'.tr(),
    ToyStatus.connected => 'toys.status_connected'.tr(),
    ToyStatus.inactive => 'toys.status_inactive'.tr(),
    ToyStatus.disconnected => 'toys.status_disconnected'.tr(),
    ToyStatus.maintenance => 'toys.status_maintenance'.tr(),
    ToyStatus.error => 'toys.status_error'.tr(),
    ToyStatus.blocked => 'toys.status_blocked'.tr(),
    ToyStatus.pending => 'toys.status_pending'.tr(),
  };

  /// Whether the toy is online and usable
  bool get isOnline => this == ToyStatus.active || this == ToyStatus.connected;
}

extension ToyPresenceUI on Toy {
  /// Status to display for this toy. `status` tracks the account lifecycle
  /// (pending/blocked/…) while `iotDeviceStatus` is the live online/offline
  /// presence the device reports over Wi-Fi; when the backend sends it, it
  /// decides connected/disconnected so the badge follows the physical toy.
  ToyStatus get displayStatus => switch (status) {
    ToyStatus.pending ||
    ToyStatus.blocked ||
    ToyStatus.error ||
    ToyStatus.maintenance => status,
    _ => switch (iotDeviceStatus) {
      'online' => ToyStatus.connected,
      'offline' => ToyStatus.disconnected,
      _ => status,
    },
  };
}
