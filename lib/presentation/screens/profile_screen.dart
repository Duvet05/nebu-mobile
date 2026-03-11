import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/edit_profile_screen.dart';
import '../widgets/custom_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.value;

    final localAvatar = ref.watch(localAvatarProvider).value;
    final themeAsync = ref.watch(themeProvider);
    final themeState = themeAsync.value;
    final isDark = themeState?.isDarkMode ?? false;
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'profile.title'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(context.spacing.alertPadding),
                child: Column(
                  children: [
                    // Profile Header Card - Simplified and Clean
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.panelPadding,
                        vertical: context.spacing.panelPadding,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: context.radius.panel,
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.textNormal.withValues(
                              alpha: isDark ? 0.3 : 0.08,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: context.colors.primary.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: _buildAvatar(
                              localAvatar: localAvatar,
                              networkAvatar: user?.avatar,
                              name: user?.name,
                              theme: theme,
                            ),
                          ),
                          SizedBox(width: context.spacing.alertPadding),
                          // Name and View Profile
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'profile.user'.tr(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: context.spacing.gapXs),
                                Text(
                                  'profile.view_profile'.tr(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Edit Profile Icon
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                            onPressed: () {
                              context.push(AppRoutes.editProfile.path);
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: context.spacing.sectionTitleBottomMargin),

                    // Quick Access Items
                    _SettingsCard(
                      theme: theme,
                      isDark: isDark,
                      children: [
                        _SettingsTile(
                          theme: theme,
                          icon: Icons.child_care,
                          title: 'profile.child_profile'.tr(),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: context.colors.grey400,
                          ),
                          onTap: () {
                            context.push(AppRoutes.childProfile.path);
                          },
                        ),
                        Divider(
                          height: 1,
                          indent: 56,
                          color: theme.dividerColor,
                        ),
                        _SettingsTile(
                          theme: theme,
                          icon: Icons.timer_outlined,
                          title: 'profile.usage_limits'.tr(),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: context.colors.grey400,
                          ),
                          onTap: () {
                            context.push(AppRoutes.usageLimits.path);
                          },
                        ),
                        Divider(
                          height: 1,
                          indent: 56,
                          color: theme.dividerColor,
                        ),
                        _SettingsTile(
                          theme: theme,
                          icon: Icons.notifications_outlined,
                          title: 'profile.notifications'.tr(),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: context.colors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: context.spacing.gapMd),
                              Icon(
                                Icons.chevron_right,
                                color: context.colors.grey400,
                              ),
                            ],
                          ),
                          onTap: () {
                            context.push(AppRoutes.notifications.path);
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: context.spacing.panelPadding),

                    // Account Section
                    _SettingsCard(
                      theme: theme,
                      isDark: isDark,
                      children: [
                        _SettingsTile(
                          theme: theme,
                          icon: Icons.person_outline,
                          title: 'profile.edit_profile'.tr(),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: context.colors.grey400,
                          ),
                          onTap: () {
                            context.push(AppRoutes.editProfile.path);
                          },
                        ),
                        Divider(
                          height: 1,
                          indent: 56,
                          color: theme.dividerColor,
                        ),
                        _SettingsTile(
                          theme: theme,
                          icon: Icons.privacy_tip_outlined,
                          title: 'profile.privacy'.tr(),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: context.colors.grey400,
                          ),
                          onTap: () {
                            context.push(AppRoutes.privacySettings.path);
                          },
                        ),
                        Divider(
                          height: 1,
                          indent: 56,
                          color: theme.dividerColor,
                        ),
                        _SettingsTile(
                          theme: theme,
                          icon: Icons.description_outlined,
                          title: 'privacy.terms_of_service'.tr(),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: context.colors.grey400,
                          ),
                          onTap: () {
                            context.push(AppRoutes.termsOfService.path);
                          },
                        ),
                        Divider(
                          height: 1,
                          indent: 56,
                          color: theme.dividerColor,
                        ),
                        _SettingsTile(
                          theme: theme,
                          icon: Icons.policy_outlined,
                          title: 'privacy.privacy_policy'.tr(),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: context.colors.grey400,
                          ),
                          onTap: () {
                            context.push(AppRoutes.privacyPolicy.path);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Logout Button — fixed at bottom
            Padding(
              padding: EdgeInsets.all(context.spacing.alertPadding),
              child: CustomButton(
                text: 'profile.logout'.tr(),
                variant: ButtonVariant.danger,
                isFullWidth: true,
                height: 54,
                onPressed: () async {
                  final shouldLogout = await showConfirmDialog(
                    context,
                    title: 'profile.logout'.tr(),
                    content: 'profile.logout_confirmation'.tr(),
                    confirmText: 'profile.logout'.tr(),
                    destructive: true,
                  );
                  if (!shouldLogout) return;
                  if (!context.mounted) return;
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go(AppRoutes.welcome.path);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildAvatar({
    required String? localAvatar,
    required String? networkAvatar,
    required String? name,
    required ThemeData theme,
  }) {
    if (localAvatar != null && File(localAvatar).existsSync()) {
      return ClipOval(
        child: Image.file(
          File(localAvatar),
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          semanticLabel: 'profile.title'.tr(),
        ),
      );
    }

    if (networkAvatar != null) {
      return ClipOval(
        child: Image.network(
          networkAvatar,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          semanticLabel: 'profile.title'.tr(),
          errorBuilder: (_, _, _) => _buildInitials(name, theme),
        ),
      );
    }

    return _buildInitials(name, theme);
  }

  static Widget _buildInitials(String? name, ThemeData theme) => Center(
    child: Text(
      (name ?? 'U')[0].toUpperCase(),
      style: theme.textTheme.headlineMedium?.copyWith(
        color: theme.colorScheme.primary,
      ),
    ),
  );
}

// Settings Card Widget
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.children,
    required this.theme,
    required this.isDark,
  });

  final List<Widget> children;
  final ThemeData theme;
  final bool isDark;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: context.radius.panel,
      boxShadow: [
        BoxShadow(
          color: context.colors.textNormal.withValues(
            alpha: isDark ? 0.3 : 0.08,
          ),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(children: children),
  );
}

// Settings Tile Widget
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.theme,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final ThemeData theme;
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.symmetric(
      horizontal: context.spacing.panelPadding,
      vertical: context.spacing.labelBottomMargin,
    ),
    leading: Icon(
      icon,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
      size: 24,
    ),
    title: Text(
      title,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
    ),
    trailing: trailing,
    onTap: onTap,
  );
}
