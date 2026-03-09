import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/config.dart';
import '../../core/theme/app_colors.dart';

class TermsOfServiceScreen extends ConsumerWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(title: Text('terms.title'.tr()), elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.spacing.alertPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'terms.header'.tr(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.spacing.titleBottomMarginSm),
            Text(
              'terms.last_updated'.tr(args: ['December 9, 2025']),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: context.spacing.panelPadding),

            // Introduction
            _buildSection(
              context,
              theme,
              'terms.introduction_title'.tr(),
              'terms.introduction_content'.tr(args: [Config.appName]),
            ),

            // Acceptance
            _buildSection(
              context,
              theme,
              'terms.acceptance_title'.tr(),
              'terms.acceptance_content'.tr(),
            ),

            // Use of Service
            _buildSection(
              context,
              theme,
              'terms.use_title'.tr(),
              'terms.use_content'.tr(),
            ),
            _buildBulletPoint(theme, 'terms.use_1'.tr()),
            _buildBulletPoint(theme, 'terms.use_2'.tr()),
            _buildBulletPoint(theme, 'terms.use_3'.tr()),
            _buildBulletPoint(theme, 'terms.use_4'.tr()),
            SizedBox(height: context.spacing.sectionTitleBottomMargin),

            // Account Responsibilities
            _buildSection(
              context,
              theme,
              'terms.account_title'.tr(),
              'terms.account_content'.tr(),
            ),

            // Prohibited Activities
            _buildSection(
              context,
              theme,
              'terms.prohibited_title'.tr(),
              'terms.prohibited_content'.tr(),
            ),
            _buildBulletPoint(theme, 'terms.prohibited_1'.tr()),
            _buildBulletPoint(theme, 'terms.prohibited_2'.tr()),
            _buildBulletPoint(theme, 'terms.prohibited_3'.tr()),
            _buildBulletPoint(theme, 'terms.prohibited_4'.tr()),
            _buildBulletPoint(theme, 'terms.prohibited_5'.tr()),
            SizedBox(height: context.spacing.sectionTitleBottomMargin),

            // Intellectual Property
            _buildSection(
              context,
              theme,
              'terms.ip_title'.tr(),
              'terms.ip_content'.tr(),
            ),

            // User Content
            _buildSection(
              context,
              theme,
              'terms.user_content_title'.tr(),
              'terms.user_content_content'.tr(),
            ),

            // Termination
            _buildSection(
              context,
              theme,
              'terms.termination_title'.tr(),
              'terms.termination_content'.tr(),
            ),

            // Account Deletion
            _buildSection(
              context,
              theme,
              'terms.delete_title'.tr(),
              'terms.delete_content'.tr(),
            ),
            SizedBox(height: context.spacing.titleBottomMarginSm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  await _openExternalLink(
                    context,
                    Config.deleteAccountUrl,
                  );
                },
                icon: const Icon(Icons.person_off_outlined),
                label: Text('terms.delete_button'.tr()),
              ),
            ),

            // Disclaimers
            _buildSection(
              context,
              theme,
              'terms.disclaimers_title'.tr(),
              'terms.disclaimers_content'.tr(),
            ),

            // Limitation of Liability
            _buildSection(
              context,
              theme,
              'terms.liability_title'.tr(),
              'terms.liability_content'.tr(),
            ),

            // Changes to Terms
            _buildSection(
              context,
              theme,
              'terms.changes_title'.tr(),
              'terms.changes_content'.tr(),
            ),

            // Governing Law
            _buildSection(
              context,
              theme,
              'terms.law_title'.tr(),
              'terms.law_content'.tr(),
            ),

            // Contact
            _buildSection(
              context,
              theme,
              'terms.contact_title'.tr(),
              'terms.contact_content'.tr(),
            ),

            SizedBox(height: context.spacing.sectionTitleBottomMargin),
            Container(
              padding: EdgeInsets.all(context.spacing.alertPadding),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: context.radius.tile,
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'terms.contact_info'.tr(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.spacing.paragraphBottomMarginSm),
                  _buildContactRow(theme, Icons.email, 'legal@nebu.ai'),
                  SizedBox(height: context.spacing.titleBottomMarginSm),
                  _buildContactRow(theme, Icons.language, 'www.nebu.ai'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.link_error'.tr())),
      );
    }
  }

  Widget _buildContactRow(ThemeData theme, IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 18, color: theme.colorScheme.primary),
      const SizedBox(width: 8),
      Text(text, style: theme.textTheme.bodyMedium),
    ],
  );
}
