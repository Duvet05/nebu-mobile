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
import '../widgets/custom_button.dart';

class MyToysScreen extends ConsumerStatefulWidget {
  const MyToysScreen({super.key});

  @override
  ConsumerState<MyToysScreen> createState() => _MyToysScreenState();
}

class _MyToysScreenState extends ConsumerState<MyToysScreen> {
  bool _isDeletingToy = false;

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
        final current = ref.read(toyProvider).value;
        if (current != null) {
          // Avoid duplicates (local toy already synced to backend)
          final localIds = localToys.map((t) => t.id).toSet();
          final merged = [
            ...current.where((t) => !localIds.contains(t.id)),
            ...localToys,
          ];
          notifier.setToys(merged);
        }
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

    setState(() => _isDeletingToy = true);
    try {
      if (toy.id.startsWith('local_')) {
        await ref.read(toyProvider.notifier).removeLocalToy(toy.id);
      } else {
        await ref.read(toyProvider.notifier).deleteToy(toy.id);
      }
      if (mounted) {
        context.showSuccessSnackBar(
          'toys.deleted_success'.tr(args: [toy.name]),
        );
      }
    } on Exception {
      if (mounted) {
        context.showErrorSnackBar('toys.delete_error'.tr());
      }
    } finally {
      if (mounted) {
        setState(() => _isDeletingToy = false);
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
            context.spacing.paragraphBottomMarginSm,
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
                    borderRadius: context.radius.checkbox,
                  ),
                ),
                SizedBox(height: context.spacing.panelPadding),
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
                    SizedBox(width: context.spacing.gapXl),
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
                          SizedBox(height: context.spacing.gapXs),
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
                              SizedBox(width: context.spacing.gapSm),
                              Text(
                                statusText,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
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
                  SizedBox(height: context.spacing.alertPadding),
                  Container(
                    padding: EdgeInsets.all(
                      context.spacing.paragraphBottomMarginSm,
                    ),
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
                        SizedBox(width: context.spacing.gapLg),
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
                  SizedBox(height: context.spacing.panelPadding),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(context.spacing.alertPadding),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.03,
                      ),
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
                            theme,
                            Icons.category_outlined,
                            'toys.model'.tr(),
                            toy.model!,
                          ),
                        if (toy.firmwareVersion != null)
                          _detailRow(
                            theme,
                            Icons.system_update_outlined,
                            'toys.firmware'.tr(),
                            toy.firmwareVersion!,
                          ),
                        if (toy.batteryLevel != null)
                          _detailRow(
                            theme,
                            Icons.battery_std_outlined,
                            'toys.battery'.tr(),
                            '${toy.batteryLevel}%',
                          ),
                        if (toy.signalStrength != null)
                          _detailRow(
                            theme,
                            Icons.signal_cellular_alt,
                            'toys.signal'.tr(),
                            '${toy.signalStrength} dBm',
                          ),
                        if (toy.iotDeviceId != null)
                          _detailRow(
                            theme,
                            Icons.router_outlined,
                            'toys.iot_device'.tr(),
                            toy.iotDeviceId!,
                          ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: context.spacing.panelPadding),
                // Action buttons
                CustomButton(
                  text: 'toys.configure'.tr(),
                  icon: Icons.settings,
                  isFullWidth: true,
                  borderRadius: this.context.radius.tile,
                  onPressed: _isDeletingToy
                      ? null
                      : () {
                          Navigator.pop(context);
                          this.context.push(
                            AppRoutes.toySettings.path,
                            extra: toy,
                          );
                        },
                ),
                SizedBox(height: context.spacing.paragraphBottomMarginSm),
                CustomButton(
                  text: 'toys.remove'.tr(),
                  icon: Icons.delete_outline,
                  variant: ButtonVariant.dangerOutline,
                  isFullWidth: true,
                  isLoading: _isDeletingToy,
                  borderRadius: this.context.radius.tile,
                  onPressed: _isDeletingToy
                      ? null
                      : () {
                          Navigator.pop(context);
                          _deleteToy(toy);
                        },
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

  Widget _detailRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) => Row(
    children: [
      Icon(
        icon,
        size: 16,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      SizedBox(width: context.spacing.gapLg),
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
          'toys.my_active_toys'.tr(),
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
              ] else ...[
                ...toys.map<Widget>(
                  (toy) => _ToyCard(
                    toy: toy,
                    theme: theme,
                    isDark: isDark,
                    onTap: _isDeletingToy
                        ? () {}
                        : () => _showToyDetails(toy, theme, isDark),
                  ),
                ),

                // Add another toy
                _buildAddToyCard(theme),
              ],
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
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
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.panelPadding,
          vertical: context.spacing.alertPadding,
        ),
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.05),
          borderRadius: context.radius.panel,
          border: Border.all(
            color: context.colors.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 20,
              color: context.colors.primary,
            ),
            SizedBox(width: context.spacing.gapMd),
            Text(
              'toys.add_toy'.tr(),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.primary,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildEmptyState(BuildContext context, ThemeData theme) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          child: Icon(
            Icons.smart_toy_outlined,
            size: 80,
            color: context.colors.primary,
          ),
        ),
        SizedBox(height: context.spacing.paragraphBottomMargin),
        Text(
          'toys.no_toys_title'.tr(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.spacing.sectionTitleBottomMargin),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.largePageBottomMargin,
          ),
          child: Text(
            'toys.no_toys_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(height: context.spacing.titleBottomMargin),
        CustomButton(
          text: 'toys.setup_new_toy'.tr(),
          icon: Icons.add,
          borderRadius: context.radius.button,
          onPressed: () => _addNewToy(context),
        ),
      ],
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
              CustomButton(
                text: 'common.retry'.tr(),
                icon: Icons.refresh,
                onPressed: _loadToys,
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
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15)),
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
            padding: EdgeInsets.all(context.spacing.alertPadding),
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
                    SizedBox(width: context.spacing.gapXl),
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
                          SizedBox(height: context.spacing.gapXs),
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
                              SizedBox(width: context.spacing.gapSm),
                              Text(
                                badgeText,
                                style: theme.textTheme.labelMedium?.copyWith(
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
                  SizedBox(height: context.spacing.paragraphBottomMarginSm),
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
                      SizedBox(width: context.spacing.labelBottomMargin),
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
                      SizedBox(width: context.spacing.labelBottomMargin),
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
                  SizedBox(height: context.spacing.paragraphBottomMarginSm),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: context.spacing.paragraphBottomMarginSm,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.06),
                      borderRadius: context.radius.tile,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 16,
                          color: accentColor,
                        ),
                        SizedBox(width: context.spacing.labelBottomMargin),
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
                  SizedBox(height: context.spacing.labelBottomMargin),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _formatLastConnected(toy.lastConnected!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
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
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.paragraphBottomMarginSm,
        vertical: context.spacing.labelBottomMargin,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: context.radius.tile,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: context.spacing.gapSm),
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
