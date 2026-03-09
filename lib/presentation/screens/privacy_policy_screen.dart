import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/config.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/custom_button.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(title: Text('privacy_policy.title'.tr()), elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.spacing.alertPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'privacy_policy.header'.tr(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.spacing.titleBottomMarginSm),
            Text(
              'privacy_policy.last_updated'.tr(args: ['December 9, 2025']),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: context.spacing.panelPadding),

            // Introduction
            _buildSection(
              context,
              theme,
              'privacy_policy.introduction_title'.tr(),
              'privacy_policy.introduction_content'.tr(args: [Config.appName]),
            ),

            // Information We Collect
            _buildSection(
              context,
              theme,
              'privacy_policy.collect_title'.tr(),
              'privacy_policy.collect_content'.tr(),
            ),
            _buildBulletPoint(theme, 'privacy_policy.collect_1'.tr()),
            _buildBulletPoint(theme, 'privacy_policy.collect_2'.tr()),
            _buildBulletPoint(theme, 'privacy_policy.collect_3'.tr()),
            _buildBulletPoint(theme, 'privacy_policy.collect_4'.tr()),
            SizedBox(height: context.spacing.sectionTitleBottomMargin),

            // How We Use Your Information
            _buildSection(
              context,
              theme,
              'privacy_policy.use_title'.tr(),
              'privacy_policy.use_content'.tr(),
            ),
            _buildBulletPoint(theme, 'privacy_policy.use_1'.tr()),
            _buildBulletPoint(theme, 'privacy_policy.use_2'.tr()),
            _buildBulletPoint(theme, 'privacy_policy.use_3'.tr()),
            _buildBulletPoint(theme, 'privacy_policy.use_4'.tr()),
            SizedBox(height: context.spacing.sectionTitleBottomMargin),

            // Data Sharing
            _buildSection(
              context,
              theme,
              'privacy_policy.sharing_title'.tr(),
              'privacy_policy.sharing_content'.tr(),
            ),

            // Children's Privacy
            _buildSection(
              context,
              theme,
              'privacy_policy.children_title'.tr(),
              'privacy_policy.children_content'.tr(),
            ),

            // Your Rights
            _buildSection(
              context,
              theme,
              'privacy_policy.rights_title'.tr(),
              'privacy_policy.rights_content'.tr(),
            ),
            _buildBulletPoint(theme, 'privacy_policy.rights_1'.tr()),
            _buildBulletPoint(theme, 'privacy_policy.rights_2'.tr()),
            _buildBulletPoint(theme, 'privacy_policy.rights_3'.tr()),
            _buildBulletPoint(theme, 'privacy_policy.rights_4'.tr()),
            SizedBox(height: context.spacing.sectionTitleBottomMargin),

            // Account & Data Deletion
            _buildSection(
              context,
              theme,
              'privacy_policy.delete_title'.tr(),
              'privacy_policy.delete_content'.tr(),
            ),
            SizedBox(height: context.spacing.titleBottomMarginSm),
            Wrap(
              spacing: 12,
              children: [
                CustomButton(
                  text: 'privacy_policy.delete_account_button'.tr(),
                  onPressed: () async {
                    await _openExternalLink(context, Config.deleteAccountUrl);
                  },
                  icon: Icons.person_off_outlined,
                  variant: ButtonVariant.text,
                  height: 40,
                ),
                CustomButton(
                  text: 'privacy_policy.delete_data_button'.tr(),
                  onPressed: () async {
                    await _openExternalLink(context, Config.deleteDataUrl);
                  },
                  icon: Icons.delete_sweep_outlined,
                  variant: ButtonVariant.text,
                  height: 40,
                ),
              ],
            ),
            SizedBox(height: context.spacing.sectionTitleBottomMargin),

            // Data Security
            _buildSection(
              context,
              theme,
              'privacy_policy.security_title'.tr(),
              'privacy_policy.security_content'.tr(),
            ),

            // Changes to Policy
            _buildSection(
              context,
              theme,
              'privacy_policy.changes_title'.tr(),
              'privacy_policy.changes_content'.tr(),
            ),

            // Contact
            _buildSection(
              context,
              theme,
              'privacy_policy.contact_title'.tr(),
              'privacy_policy.contact_content'.tr(),
            ),

            SizedBox(height: context.spacing.sectionTitleBottomMargin),
            Container(
              padding: EdgeInsets.all(context.spacing.alertPadding),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: context.radius.tile,
              ),
              child: Row(
                children: [
                  Icon(Icons.email, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'privacy_policy.email_label'.tr(),
                          style: theme.textTheme.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'privacy@nebu.ai',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: context.spacing.paragraphBottomMargin),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, ThemeData theme, String title, String content) =>
      Padding(
        padding: EdgeInsets.only(bottom: context.spacing.sectionTitleBottomMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.spacing.titleBottomMarginSm),
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      );

  Widget _buildBulletPoint(ThemeData theme, String text) => Padding(
    padding: const EdgeInsets.only(left: 16, bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• ', style: theme.textTheme.bodyMedium),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
      ],
    ),
  );

  Future<void> _openExternalLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('profile.link_error'.tr())));
    }
  }
}
