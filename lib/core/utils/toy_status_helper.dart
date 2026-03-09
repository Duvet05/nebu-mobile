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
