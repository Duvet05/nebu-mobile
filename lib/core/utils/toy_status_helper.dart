import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../data/models/toy.dart';
import '../theme/app_colors.dart';

extension ToyStatusUI on ToyStatus {
  Color color(BuildContext context) => switch (this) {
    ToyStatus.pending => context.colors.warning,
    ToyStatus.active => context.colors.success,
    _ => context.colors.error,
  };

  String label() => switch (this) {
    ToyStatus.pending => 'toys.pending'.tr(),
    ToyStatus.active => 'toys.online'.tr(),
    _ => 'toys.offline'.tr(),
  };
}
