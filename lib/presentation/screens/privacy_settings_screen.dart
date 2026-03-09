import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../providers/api_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  bool _profileVisible = true;
  bool _shareActivityData = false;
  bool _analyticsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(title: Text('privacy.title'.tr()), elevation: 0),
      body: ListView(
        padding: EdgeInsets.all(context.spacing.alertPadding),
        children: [
          // Profile Visibility Section
          _buildSectionHeader('privacy.profile_visibility'.tr(), theme),
          _buildCard(
            theme,
            children: [
              SwitchListTile(
                title: Text('privacy.public_profile'.tr()),
                subtitle: Text('privacy.public_profile_desc'.tr()),
                value: _profileVisible,
                onChanged: (value) {
                  setState(() => _profileVisible = value);
                },
              ),
            ],
          ),

          SizedBox(height: context.spacing.panelPadding),

          // Data Sharing Section
          _buildSectionHeader('privacy.data_sharing'.tr(), theme),
          _buildCard(
            theme,
            children: [
              SwitchListTile(
                title: Text('privacy.share_activity'.tr()),
                subtitle: Text('privacy.share_activity_desc'.tr()),
                value: _shareActivityData,
                onChanged: (value) {
                  setState(() => _shareActivityData = value);
                },
              ),
              const Divider(),
              SwitchListTile(
                title: Text('privacy.analytics'.tr()),
                subtitle: Text('privacy.analytics_desc'.tr()),
                value: _analyticsEnabled,
                onChanged: (value) {
                  setState(() => _analyticsEnabled = value);
                },
              ),
            ],
          ),

          SizedBox(height: context.spacing.panelPadding),

          // App Permissions Section
          _buildSectionHeader('privacy.permissions'.tr(), theme),
          _buildCard(
            theme,
            children: [
              _buildPermissionTile(
                theme,
                Icons.bluetooth,
                'privacy.bluetooth'.tr(),
                'privacy.bluetooth_desc'.tr(),
                true,
              ),
              const Divider(),
              _buildPermissionTile(
                theme,
                Icons.camera_alt,
                'privacy.camera'.tr(),
                'privacy.camera_desc'.tr(),
                true,
              ),
              const Divider(),
              _buildPermissionTile(
                theme,
                Icons.location_on,
                'privacy.location'.tr(),
                'privacy.location_desc'.tr(),
                false,
              ),
              const Divider(),
              _buildPermissionTile(
                theme,
                Icons.mic,
                'privacy.microphone'.tr(),
                'privacy.microphone_desc'.tr(),
                true,
              ),
            ],
          ),

          SizedBox(height: context.spacing.panelPadding),

          // Account Data Section
          _buildSectionHeader('privacy.account_data'.tr(), theme),
          _buildCard(
            theme,
            children: [
              ListTile(
                leading: Icon(Icons.download, color: theme.colorScheme.primary),
                title: Text('privacy.download_data'.tr()),
                subtitle: Text('privacy.download_data_desc'.tr()),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showDownloadDataDialog,
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.history, color: theme.colorScheme.primary),
                title: Text('privacy.login_history'.tr()),
                subtitle: Text('privacy.login_history_desc'.tr()),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showLoginHistoryDialog,
              ),
            ],
          ),

          SizedBox(height: context.spacing.panelPadding),

          // Legal Section
          _buildSectionHeader('privacy.legal'.tr(), theme),
          _buildCard(
            theme,
            children: [
              ListTile(
                leading: Icon(
                  Icons.description,
                  color: theme.colorScheme.primary,
                ),
                title: Text('privacy.privacy_policy'.tr()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push(AppRoutes.privacyPolicy.path);
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.gavel, color: theme.colorScheme.primary),
                title: Text('privacy.terms_of_service'.tr()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push(AppRoutes.termsOfService.path);
                },
              ),
            ],
          ),

          SizedBox(height: context.spacing.panelPadding),

          // Danger Zone
          _buildSectionHeader('privacy.danger_zone'.tr(), theme),
          _buildCard(
            theme,
            children: [
              ListTile(
                leading: Icon(Icons.delete_forever, color: context.colors.error),
                title: Text(
                  'privacy.delete_account'.tr(),
                  style: TextStyle(color: context.colors.error),
                ),
                subtitle: Text('privacy.delete_account_desc'.tr()),
                trailing: Icon(Icons.chevron_right, color: context.colors.error),
                onTap: _showDeleteAccountDialog,
              ),
            ],
          ),

          SizedBox(height: context.spacing.paragraphBottomMargin),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) => Padding(
    padding: EdgeInsets.only(left: context.spacing.gapXs, bottom: context.spacing.gapLg),
    child: Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    ),
  );

  Widget _buildCard(ThemeData theme, {required List<Widget> children}) =>
      DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: context.radius.panel,
          boxShadow: [
            BoxShadow(
              color: context.colors.textNormal.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: children),
      );

  Widget _buildPermissionTile(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
    bool granted,
  ) => ListTile(
    leading: Icon(icon, color: theme.colorScheme.primary),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: Chip(
      label: Text(
        granted ? 'privacy.granted'.tr() : 'privacy.denied'.tr(),
        style: TextStyle(
          fontSize: 12,
          color: granted ? context.colors.success : context.colors.warning,
        ),
      ),
      backgroundColor: granted
          ? context.colors.success.withValues(alpha: 0.1)
          : context.colors.warning.withValues(alpha: 0.1),
    ),
    onTap: () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('privacy.manage_in_settings'.tr()),
          action: SnackBarAction(
            label: 'privacy.open_settings'.tr(),
            onPressed: openAppSettings,
          ),
        ),
      );
    },
  );

  void _showDownloadDataDialog() {
    unawaited(showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('privacy.download_data'.tr()),
        content: Text('privacy.download_data_info'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          CustomButton(
            text: 'privacy.download'.tr(),
            onPressed: () {
              Navigator.pop(context);
              context.showInfoSnackBar('privacy.download_started'.tr());
            },
          ),
        ],
      ),
    ));
  }

  void _showLoginHistoryDialog() {
    unawaited(showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('privacy.login_history'.tr()),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLoginHistoryItem(
                'Android Device',
                'Lima, Peru',
                'Just now',
                true,
              ),
              const Divider(),
              _buildLoginHistoryItem(
                'Web Browser',
                'Lima, Peru',
                '2 days ago',
                false,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('privacy.close'.tr()),
          ),
        ],
      ),
    ));
  }

  Widget _buildLoginHistoryItem(
    String device,
    String location,
    String time,
    bool current,
  ) => ListTile(
    leading: Icon(
      Icons.phone_android,
      color: current ? context.colors.success : context.colors.grey400,
    ),
    title: Text(device),
    subtitle: Text('$location • $time'),
    trailing: current
        ? Chip(
            label: Text(
              'privacy.current'.tr(),
              style: context.textTheme.labelSmall,
            ),
            backgroundColor: context.colors.success.withValues(alpha: 0.1),
          )
        : null,
  );

  void _showDeleteAccountDialog() {
    unawaited(showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'privacy.delete_account'.tr(),
          style: TextStyle(color: context.colors.error),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('privacy.delete_account_warning'.tr()),
            SizedBox(height: context.spacing.sectionTitleBottomMargin),
            Text(
              'privacy.delete_account_consequences'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: context.spacing.titleBottomMarginSm),
            Text('• ${'privacy.consequence_1'.tr()}'),
            Text('• ${'privacy.consequence_2'.tr()}'),
            Text('• ${'privacy.consequence_3'.tr()}'),
            Text('• ${'privacy.consequence_4'.tr()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          CustomButton(
            text: 'privacy.delete_permanently'.tr(),
            variant: ButtonVariant.danger,
            onPressed: () async {
              Navigator.pop(context);
              final password = await _confirmDeleteAccount();
              if (password != null && mounted) {
                await _performAccountDeletion(password);
              }
            },
          ),
        ],
      ),
    ));
  }

  Future<void> _performAccountDeletion(String password) async {
    try {
      final userService = ref.read(userServiceProvider);
      await userService.deleteOwnAccount(password: password);
      await ref.read(authProvider.notifier).logout();
      if (!mounted) {
        return;
      }
      context
        ..showInfoSnackBar('privacy.account_deleted_success'.tr())
        ..go(AppRoutes.welcome.path);
    } on Exception catch (e) {
      if (!mounted) {
        return;
      }
      context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String?> _confirmDeleteAccount() {
    final confirmController = TextEditingController();
    final passwordController = TextEditingController();
    return showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('privacy.confirm_deletion'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('privacy.type_delete_to_confirm'.tr()),
            SizedBox(height: context.spacing.sectionTitleBottomMargin),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(
                hintText: 'DELETE',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: context.spacing.sectionTitleBottomMargin),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'privacy.enter_password'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          CustomButton(
            text: 'common.delete'.tr(),
            variant: ButtonVariant.danger,
            onPressed: () {
              if (confirmController.text.toUpperCase() != 'DELETE') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('privacy.incorrect_confirmation'.tr()),
                    backgroundColor: context.colors.error,
                  ),
                );
                return;
              }
              if (passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('privacy.password_required'.tr()),
                    backgroundColor: context.colors.error,
                  ),
                );
                return;
              }
              Navigator.pop(context, passwordController.text);
            },
          ),
        ],
      ),
    );
  }
}
