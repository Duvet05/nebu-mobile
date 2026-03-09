import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/toy_status_helper.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/toy.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/toy_provider.dart';

class MyToysScreen extends ConsumerStatefulWidget {
  const MyToysScreen({super.key});

  @override
  ConsumerState<MyToysScreen> createState() => _MyToysScreenState();
}

class _MyToysScreenState extends ConsumerState<MyToysScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Skip reload if toys are already loaded (prevents error on back-navigation)
      final existing = ref.read(toyProvider);
      if (!existing.hasValue || existing.value!.isEmpty) {
        _loadToys();
      }
    });
  }

  Future<void> _loadToys() async {
    final user = ref.read(authProvider).value;
    final notifier = ref.read(toyProvider.notifier);

    // Always load local toys first so we never flash a false empty state
    final localToys = await notifier.loadLocalToys();

    if (user != null) {
      // Authenticated: load from backend, then merge local toys
      await notifier.loadMyToys();
      if (localToys.isNotEmpty) {
        final current = ref.read(toyProvider).value ?? [];
        // Avoid duplicates (local toy already synced to backend)
        final localIds = localToys.map((t) => t.id).toSet();
        final merged = [
          ...current.where((t) => !localIds.contains(t.id)),
          ...localToys
        ];
        notifier.setToys(merged);
      }
    } else {
      // Unauthenticated: only local toys
      notifier.setToys(localToys);
    }
  }

  Future<void> _deleteToy(Toy toy) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'toys.delete_title'.tr(),
      content: 'toys.delete_confirm'.tr(args: [toy.name]),
      destructive: true,
    );

    if (!confirmed || !mounted) {
      return;
    }

    try {
      if (toy.id.startsWith('local_')) {
        await ref.read(toyProvider.notifier).removeLocalToy(toy.id);
      } else {
        await ref.read(toyProvider.notifier).deleteToy(toy.id);
      }
      if (mounted) {
        context.showSuccessSnackBar(
            'toys.deleted_success'.tr(args: [toy.name]));
      }
    } on Exception {
      if (mounted) {
        context.showErrorSnackBar('toys.delete_error'.tr());
      }
    }
  }

  void _showToyDetails(Toy toy, ThemeData theme, bool isDark) {
    final isPending = toy.status == ToyStatus.pending;
    final statusColor = toy.status.color(context);
    final statusText = toy.status.label();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.spacing.pageMargin,
            12,
            context.spacing.pageMargin,
            context.spacing.pageMargin,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                // Header: icon + name + status on one row
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.smart_toy,
                        size: 28,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            toy.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Pending warning
                if (isPending) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.warning.withValues(alpha: 0.08),
                      borderRadius: context.radius.tile,
                      border: Border.all(
                        color: context.colors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: context.colors.warning,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'toys.pending_hint'.tr(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: context.colors.warning,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Toy details
                if (_hasAnyDetail(toy)) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                      borderRadius: context.radius.tile,
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      spacing: 10,
                      children: [
                        if (toy.model != null)
                          _detailRow(
                            theme, Icons.category_outlined,
                            'toys.model'.tr(), toy.model!,
                          ),
                        if (toy.firmwareVersion != null)
                          _detailRow(
                            theme, Icons.system_update_outlined,
                            'toys.firmware'.tr(), toy.firmwareVersion!,
                          ),
                        if (toy.batteryLevel != null)
                          _detailRow(
                            theme, Icons.battery_std_outlined,
                            'toys.battery'.tr(), '${toy.batteryLevel}%',
                          ),
                        if (toy.signalStrength != null)
                          _detailRow(
                            theme, Icons.signal_cellular_alt,
                            'toys.signal'.tr(), '${toy.signalStrength} dBm',
                          ),
                        if (toy.iotDeviceId != null)
                          _detailRow(
                            theme, Icons.router_outlined,
                            'toys.iot_device'.tr(), toy.iotDeviceId!,
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                // Action buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.toySettings.path, extra: toy);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: context.colors.textOnFilled,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: context.radius.tile,
                      ),
                    ),
                    icon: const Icon(Icons.settings, size: 20),
                    label: Text('toys.configure'.tr()),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteToy(toy);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.error,
                      side: BorderSide(
                        color: context.colors.error.withValues(alpha: 0.4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: context.radius.tile,
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: Text('toys.remove'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _hasAnyDetail(Toy toy) =>
      toy.model != null ||
      toy.firmwareVersion != null ||
      toy.batteryLevel != null ||
      toy.signalStrength != null ||
      toy.iotDeviceId != null;

  Widget _detailRow(ThemeData theme, IconData icon, String label, String value) =>
      Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
          const SizedBox(width: 10),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      );

  void _addNewToy(BuildContext context) {
    context.push(AppRoutes.connectionSetup.path);
  }

  @override
  Widget build(BuildContext context) {
    final themeAsync = ref.watch(themeProvider);
    final themeState = themeAsync.value;
    final isDark = themeState?.isDarkMode ?? false;
    final theme = context.theme;
    final toysAsync = ref.watch(toyProvider);

    // Handle errors
    ref.listen(toyProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        context.showErrorSnackBar('toys.error_loading'.tr());
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'toys.title'.tr(),
          style: theme.appBarTheme.titleTextStyle?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addNewToy(context),
            tooltip: 'toys.add_toy'.tr(),
          ),
        ],
      ),
      body: toysAsync.when(
        data: (toys) => RefreshIndicator(
            onRefresh: _loadToys,
            child: ListView(
              padding: EdgeInsets.all(context.spacing.alertPadding),
              children: [
                if (toys.isEmpty) ...[
                  _buildEmptyState(context, theme),
                ] else
                  ...[
                    ...toys.map<Widget>(
                          (toy) =>
                          _ToyCard(
                            toy: toy,
                            theme: theme,
                            isDark: isDark,
                            onTap: () => _showToyDetails(toy, theme, isDark),
                          ),
                    ),

                    // Add another toy
                    _buildAddToyCard(theme),
                  ],
              ],
            ),
          ),
        loading: () => _buildLoadingSkeleton(theme),
        error: (_, _) => _buildErrorState(theme),
      ),
    );
  }

  Widget _buildAddToyCard(ThemeData theme) => Padding(
    padding: EdgeInsets.only(top: context.spacing.paragraphBottomMarginSm),
    child: InkWell(
      onTap: () => _addNewToy(context),
      borderRadius: context.radius.panel,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.colors.primary.withValues(alpha: 0.04),
              context.colors.secondary.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: context.radius.panel,
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.primary.withValues(alpha: 0.08),
                    context.colors.secondary.withValues(alpha: 0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                size: 36,
                color: context.colors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'toys.setup_new_toy'.tr(),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'toys.add_more_hint'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildEmptyState(BuildContext context, ThemeData theme) => Container(
    padding: EdgeInsets.all(context.spacing.paragraphBottomMargin),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          context.colors.primary.withValues(alpha: 0.04),
          context.colors.secondary.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: context.radius.panel,
      border: Border.all(
        color: theme.dividerColor.withValues(alpha: 0.3),
        width: 2,
      ),
    ),
    child: Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.primary.withValues(alpha: 0.08),
                context.colors.secondary.withValues(alpha: 0.08),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.smart_toy_outlined,
            size: 48,
            color: context.colors.primary.withValues(alpha: 0.5),
          ),
        ),
        SizedBox(height: context.spacing.sectionTitleBottomMargin),
        Text(
          'toys.no_toys_title'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.spacing.titleBottomMarginSm),
        Text(
          'toys.no_toys_subtitle'.tr(),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: context.spacing.titleBottomMargin),
        ElevatedButton.icon(
          onPressed: () => _addNewToy(context),
          icon: const Icon(Icons.add),
          label: Text('toys.setup_new_toy'.tr()),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: context.colors.textOnFilled,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: context.radius.button,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildLoadingSkeleton(ThemeData theme) => ListView(
    padding: EdgeInsets.all(context.spacing.alertPadding),
    physics: const NeverScrollableScrollPhysics(),
    children: List.generate(
      3,
      (_) => Container(
        margin: EdgeInsets.only(bottom: context.spacing.paragraphBottomMarginSm),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: context.radius.panel,
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildErrorState(ThemeData theme) => RefreshIndicator(
    onRefresh: _loadToys,
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(context.spacing.pageMargin),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              SizedBox(height: context.spacing.sectionTitleBottomMargin),
              Text(
                'toys.error_loading'.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacing.panelPadding),
              ElevatedButton.icon(
                onPressed: _loadToys,
                icon: const Icon(Icons.refresh),
                label: Text('common.retry'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: context.colors.textOnFilled,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ToyCard extends StatelessWidget {
  const _ToyCard({
    required this.toy,
    required this.theme,
    required this.isDark,
    required this.onTap,
  });

  final Toy toy;
  final ThemeData theme;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isOnline = toy.status.isOnline;
    final isPending = toy.status == ToyStatus.pending;
    final accentColor = toy.status.color(context);
    final badgeText = toy.status.label();

    return Container(
      margin: EdgeInsets.only(bottom: context.spacing.paragraphBottomMarginSm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: context.radius.panel,
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: context.radius.panel,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Toy Icon (circle)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.smart_toy,
                        size: 24,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Name + status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            toy.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                badgeText,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: accentColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.iconTheme.color?.withValues(alpha: 0.3),
                    ),
                  ],
                ),
                // Quick action buttons for online toys
                if (isOnline) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.record_voice_over,
                          label: 'toys.talk_to_toy'.tr(),
                          color: context.colors.primary,
                          onTap: () => context.push(
                            AppRoutes.walkieTalkie.path,
                            extra: toy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.psychology,
                          label: 'toys.memory'.tr(),
                          color: context.colors.warning,
                          onTap: () => context.push(
                            AppRoutes.toyMemory.path,
                            extra: toy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.settings,
                          label: 'toys.configure_toy'.tr(),
                          color: context.colors.secondary,
                          onTap: () => context.push(
                            AppRoutes.toySettings.path,
                            extra: toy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                // Configure prompt for pending toys
                if (isPending) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.06),
                      borderRadius: context.radius.tile,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.touch_app_outlined, size: 16, color: accentColor),
                        const SizedBox(width: 8),
                        Text(
                          'toys.configure'.tr(),
                          style: context.textTheme.labelMedium?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Last connected time for offline toys
                if (!isOnline && !isPending && toy.lastConnected != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _formatLastConnected(toy.lastConnected!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatLastConnected(DateTime lastConnected) {
    final now = DateTime.now();
    final diff = now.difference(lastConnected);
    if (diff.inMinutes < 1) {
      return 'activity_log.just_now'.tr();
    }
    if (diff.inHours < 1) {
      return 'activity_log.minutes_ago'.tr(args: [diff.inMinutes.toString()]);
    }
    if (diff.inDays < 1) {
      return 'activity_log.hours_ago'.tr(args: [diff.inHours.toString()]);
    }
    return 'activity_log.days_ago'.tr(args: [diff.inDays.toString()]);
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: context.radius.tile,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: context.radius.tile,
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}


