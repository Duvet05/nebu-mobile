import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../widgets/custom_button.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _openSupport(BuildContext context) async {
    final uri = Uri.parse(Config.supportUrl);
    var launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception {
      launched = false;
    }

    if (!launched && context.mounted) {
      context.showErrorSnackBar('profile.link_error'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(title: Text('profile.help_support'.tr()), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.spacing.alertPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'profile.help_need_help'.tr(),
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(height: context.spacing.panelPadding),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(context.spacing.alertPadding),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: context.radius.panel,
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.language, color: theme.colorScheme.primary),
                        SizedBox(width: context.spacing.gapLg),
                        Expanded(
                          child: SelectableText(
                            Config.supportUrl,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing.alertPadding),
                    CustomButton(
                      text: 'profile.open_support'.tr(),
                      onPressed: () => _openSupport(context),
                      icon: Icons.open_in_new,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.spacing.panelPadding),
              _HelpOption(
                icon: Icons.email,
                title: 'profile.help_email'.tr(),
                subtitle: 'profile.help_contact_email'.tr(),
              ),
              SizedBox(height: context.spacing.titleBottomMarginSm),
              _HelpOption(
                icon: Icons.phone,
                title: 'profile.help_phone'.tr(),
                subtitle: 'profile.help_contact_phone'.tr(),
              ),
              SizedBox(height: context.spacing.titleBottomMarginSm),
              _HelpOption(
                icon: Icons.chat,
                title: 'profile.help_chat'.tr(),
                subtitle: 'profile.help_chat_hours'.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpOption extends StatelessWidget {
  const _HelpOption({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        SizedBox(width: context.spacing.paragraphBottomMarginSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: context.spacing.gapXs),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
