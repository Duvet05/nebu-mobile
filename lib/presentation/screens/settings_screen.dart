import 'package:country_flags/country_flags.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/config.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../providers/api_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider).value != null;
    final appVersion =
        ref.watch(packageInfoProvider).whenData((info) => info.version).value ??
            '';
    final themeAsync = ref.watch(themeProvider);
    final languageAsync = ref.watch(languageProvider);
    final themeState = themeAsync.value;
    final languageState = languageAsync.value;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'profile.settings'.tr(),
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
                    _SettingsTile(
                      theme: theme,
                      icon: Icons.dark_mode_outlined,
                      iconColor: context.colors.secondary,
                      title: 'profile.dark_mode'.tr(),
                      trailing: Switch(
                        value: themeState?.isDarkMode ?? false,
                        onChanged: (value) {
                          ref.read(themeProvider.notifier).toggleDarkMode();
                        },
                        activeTrackColor:
                            context.colors.primary.withValues(alpha: 0.5),
                        thumbColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return context.colors.primary;
                          }
                          return null;
                        }),
                      ),
                    ),

                    _SettingsTile(
                      theme: theme,
                      icon: Icons.language_outlined,
                      iconColor: context.colors.primary,
                      title: 'profile.language'.tr(),
                      trailing: DropdownButton<String>(
                        value: languageState?.languageCode ?? 'en',
                        underline: const SizedBox(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        dropdownColor: theme.colorScheme.surface,
                        items: [
                          DropdownMenuItem(
                            value: 'en',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CountryFlag.fromLanguageCode('en',
                                    theme: const ImageTheme(
                                        height: 24, width: 32)),
                                const SizedBox(width: 8),
                                const Text('English'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'es',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CountryFlag.fromLanguageCode('es',
                                    theme: const ImageTheme(
                                        height: 24, width: 32)),
                                const SizedBox(width: 8),
                                const Text('Español'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            context.setLocale(Locale(value));
                            ref
                                .read(languageProvider.notifier)
                                .setLanguage(value);
                          }
                        },
                      ),
                    ),

                    SizedBox(height: context.spacing.paragraphBottomMarginSm),

                    _SettingsTile(
                      theme: theme,
                      icon: Icons.help_outline,
                      iconColor: context.colors.success,
                      title: 'profile.help_support'.tr(),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: context.colors.grey400,
                      ),
                      onTap: () {
                        _showHelpDialog(context);
                      },
                    ),

                    _SettingsTile(
                      theme: theme,
                      icon: Icons.monitor_heart_outlined,
                      iconColor: context.colors.info,
                      title: 'health_check.title'.tr(),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: context.colors.grey400,
                      ),
                      onTap: () =>
                          context.push(AppRoutes.healthCheck.path),
                    ),

                    _SettingsTile(
                      theme: theme,
                      icon: Icons.info_outline,
                      iconColor: context.colors.warning,
                      title: 'profile.about'.tr(),
                      trailing: Text(
                        'v$appVersion',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      onTap: () {
                        _showAboutAppDialog(context, appVersion);
                      },
                    ),

                    SizedBox(height: context.spacing.panelPadding),
                  ],
                ),
              ),
            ),

            // Conditional Sign In button at bottom
            if (!isLoggedIn)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing.alertPadding,
                  vertical: context.spacing.paragraphBottomMarginSm,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.login.path),
                  icon: const Icon(Icons.login),
                  label: Text(
                    'auth.sign_in'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: context.colors.textOnFilled,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.textOnFilled,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: context.radius.button,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void _showHelpDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('profile.help_support_title'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('profile.help_need_help'.tr()),
          SizedBox(height: context.spacing.sectionTitleBottomMargin),
          _buildHelpOption(
            Icons.email,
            'profile.help_email'.tr(),
            'support@nebu.ai',
          ),
          SizedBox(height: context.spacing.titleBottomMarginSm),
          _buildHelpOption(
            Icons.phone,
            'profile.help_phone'.tr(),
            '+1 (555) 123-4567',
          ),
          SizedBox(height: context.spacing.titleBottomMarginSm),
          _buildHelpOption(
            Icons.chat,
            'profile.help_chat'.tr(),
            'profile.help_chat_hours'.tr(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('profile.help_close'.tr()),
        ),
      ],
    ),
  );
}

Widget _buildHelpOption(IconData icon, String title, String subtitle) =>
    Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        );
      },
    );

void _showAboutAppDialog(BuildContext context, String appVersion) {
  showAboutDialog(
    context: context,
    applicationName: Config.appName,
    applicationVersion: appVersion,
    applicationIcon: Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [context.colors.primary, context.colors.secondary]),
        borderRadius: context.radius.panel,
      ),
      child: Icon(Icons.smart_toy,
          color: context.colors.textOnFilled, size: 32),
    ),
    children: [
      SizedBox(height: context.spacing.sectionTitleBottomMargin),
      Text('profile.about_description'.tr()),
      SizedBox(height: context.spacing.titleBottomMarginSm),
      Text('profile.about_copyright'.tr()),
    ],
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.theme,
    required this.icon,
    required this.title,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  final ThemeData theme;
  final IconData icon;
  final String title;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        iconColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.8);

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: context.radius.tile,
        ),
        child: Icon(icon, color: color, size: 22),
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
}
