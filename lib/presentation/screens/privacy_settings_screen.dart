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
                leading: Icon(
                  Icons.delete_forever,
                  color: context.colors.error,
                ),
                title: Text(
                  'privacy.delete_account'.tr(),
                  style: TextStyle(color: context.colors.error),
                ),
                subtitle: Text('privacy.delete_account_desc'.tr()),
                trailing: Icon(
                  Icons.chevron_right,
                  color: context.colors.error,
                ),
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
    padding: EdgeInsets.only(
      left: context.spacing.gapXs,
      bottom: context.spacing.gapLg,
    ),
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
        style: context.textTheme.labelSmall?.copyWith(
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
    unawaited(
      showDialog<void>(
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
      ),
    );
  }

  void _showDeleteAccountDialog() {
    unawaited(
      showDialog<void>(
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
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
      ),
    );
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
              decoration: InputDecoration(
                hintText: 'privacy.delete_hint'.tr(),
                border: const OutlineInputBorder(),
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
