import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
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
    // Load toys when screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadToys();
    });
  }

  Future<void> _loadToys() async {
    final user = ref.read(authProvider).value;
    final notifier = ref.read(toyProvider.notifier);

    if (user != null) {
      // Authenticated: load from backend + local
      await notifier.loadMyToys();
      final localToys = await notifier.loadLocalToys();
      if (localToys.isNotEmpty) {
        final current = ref.read(toyProvider).value ?? [];
        notifier.setToys([...current, ...localToys]);
      }
    } else {
      // Unauthenticated: only local toys
      final localToys = await notifier.loadLocalToys();
      notifier.setToys(localToys);
    }
  }

  Future<void> _deleteToy(Toy toy) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('toys.delete_title'.tr()),
        content: Text('toys.delete_confirm'.tr(args: [toy.name])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      if (toy.id.startsWith('local_')) {
        await ref.read(toyProvider.notifier).removeLocalToy(toy.id);
      } else {
        await ref.read(toyProvider.notifier).deleteToy(toy.id);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('toys.deleted_success'.tr(args: [toy.name])),
            backgroundColor: context.colors.success,
          ),
        );
      }
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('toys.delete_error'.tr()),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  void _showToyDetails(Toy toy, ThemeData theme, bool isDark) {
    final isOnline = toy.status == ToyStatus.active;
    final isPending = toy.status == ToyStatus.pending;

    Color statusColor;
    String statusText;
    if (isPending) {
      statusColor = context.colors.warning;
      statusText = 'toys.pending'.tr();
    } else if (isOnline) {
      statusColor = context.colors.success;
      statusText = 'toys.online'.tr();
    } else {
      statusColor = context.colors.error;
      statusText = 'toys.offline'.tr();
    }

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
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.smart_toy,
                  size: 32,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 14),
              // Name
              Text(
                toy.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Status pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
              ),
              // Pending warning
              if (isPending) ...[
                const SizedBox(height: 16),
                Row(
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
              ],
              const SizedBox(height: 24),
              // Configure button
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
              // Remove button
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

  void _addNewToy(BuildContext context) {
    context.push(AppRoutes.connectionSetup.path);
  }

  @override
  Widget build(BuildContext context) {
    final themeAsync = ref.watch(themeProvider);
    final themeState = themeAsync.value;
    final isDark = themeState?.isDarkMode ?? false;
    final theme = Theme.of(context);
    final toysAsync = ref.watch(toyProvider);

    // Handle errors
    ref.listen(toyProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('toys.error_loading'.tr()),
            backgroundColor: context.colors.error,
          ),
        );
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
                    // Empty state
                    _buildEmptyState(context, theme),
                  ] else ...[
                    // Display toys from API
                    ...toys.map<Widget>(
                      (toy) => _ToyCard(
                        toy: toy,
                        theme: theme,
                        isDark: isDark,
                        onTap: () => _showToyDetails(toy, theme, isDark),
                      ),
                    ),
                  ],

                  if (toys.isNotEmpty) ...[
                    SizedBox(height: context.spacing.panelPadding),
                    // Add more hint
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.alertPadding,
                        vertical: context.spacing.paragraphBottomMarginSm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.smart_toy_outlined,
                            size: 18,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'toys.add_more_hint'.tr(),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => RefreshIndicator(
          onRefresh: _loadToys,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(context.spacing.pageMargin),
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
                  SizedBox(height: context.spacing.paragraphBottomMarginSm),
                  Container(
                    padding: EdgeInsets.all(context.spacing.alertPadding),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                      borderRadius: context.radius.tile,
                      border: Border.all(
                        color: theme.colorScheme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'toys.error_loading'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
      ),
    );
  }

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
    final isOnline = toy.status == ToyStatus.active;
    final isPending = toy.status == ToyStatus.pending;

    Color accentColor;
    String badgeText;
    if (isPending) {
      accentColor = context.colors.warning;
      badgeText = 'toys.pending'.tr();
    } else if (isOnline) {
      accentColor = context.colors.success;
      badgeText = 'toys.online'.tr();
    } else {
      accentColor = context.colors.error;
      badgeText = 'toys.offline'.tr();
    }

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
              style: TextStyle(
                fontSize: 12,
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
