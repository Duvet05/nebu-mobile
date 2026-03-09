import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/services/local_child_data_service.dart';
import '../providers/api_provider.dart';
import '../widgets/custom_button.dart';

class ChildProfileScreen extends ConsumerWidget {
  const ChildProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localChildDataService = ref.watch(localChildDataServiceProvider);
    final colorScheme = context.theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('child_profile.title'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: localChildDataService.when(
        data: (service) {
          if (!service.hasChildData()) {
            return _buildNoChildDataState(context, service, colorScheme);
          }
          return _buildChildProfileState(context, service, colorScheme);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            Center(child: Text('child_profile.error_generic'.tr())),
      ),
    );
  }

  Widget _buildNoChildDataState(
    BuildContext context,
    LocalChildDataService service,
    ColorScheme colorScheme,
  ) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.child_care, size: 80, color: context.colors.grey500),
        SizedBox(height: context.spacing.titleBottomMargin),
        Text(
          'child_profile.no_data_title'.tr(),
          style: context.textTheme.headlineSmall,
        ),
        SizedBox(height: context.spacing.paragraphBottomMarginSm),
        Text(
          'child_profile.no_data_subtitle'.tr(),
          textAlign: TextAlign.center,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colors.grey500,
          ),
        ),
        SizedBox(height: context.spacing.paragraphBottomMargin),
        CustomButton(
          text: 'child_profile.setup_profile'.tr(),
          onPressed: () => context.push(AppRoutes.toyNameSetup.path),
        ),
      ],
    ),
  );

  Widget _buildChildProfileState(
    BuildContext context,
    LocalChildDataService service,
    ColorScheme colorScheme,
  ) {
    final childData = service.getChildData();
    final childName = childData['name'] ?? 'Child';
    final childAge = childData['age'];
    final childPersonality = childData['personality'];

    return Padding(
      padding: EdgeInsets.all(context.spacing.alertPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    childName.isNotEmpty ? childName[0].toUpperCase() : '?',
                    style: context.theme.textTheme.headlineLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(height: context.spacing.paragraphBottomMarginSm),
                Text(
                  childName,
                  style: context.theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (childAge != null)
                  Text(
                    'child_profile.age'.tr(args: [childAge]),
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colors.grey500,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: context.spacing.paragraphBottomMargin),
          const Divider(),
          _buildSectionTitle('child_profile.personality'.tr(), context),
          Wrap(
            spacing: 8,
            children: [
              if (childPersonality != null)
                _buildInfoChip(childPersonality, Icons.psychology, colorScheme),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                text: 'profile.edit_profile'.tr(),
                onPressed: () => context.push(AppRoutes.toyNameSetup.path),
                variant: ButtonVariant.text,
                icon: Icons.edit,
              ),
              CustomButton(
                text: 'child_profile.delete_profile'.tr(),
                onPressed: () => _confirmDelete(context, service, colorScheme),
                variant: ButtonVariant.text,
                icon: Icons.delete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: context.spacing.alertPadding),
    child: Text(
      title,
      style: context.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: context.colors.textNormal,
      ),
    ),
  );

  Widget _buildInfoChip(String label, IconData icon, ColorScheme colorScheme) =>
      Chip(
        avatar: Icon(icon, color: colorScheme.primary, size: 18),
        label: Text(label),
        backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
        labelStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        shape: StadiumBorder(
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.2)),
        ),
      );

  Future<void> _confirmDelete(
    BuildContext context,
    LocalChildDataService service,
    ColorScheme colorScheme,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'child_profile.confirm_deletion_title'.tr(),
      content: 'child_profile.confirm_deletion_message'.tr(),
      destructive: true,
    );
    if (confirmed) {
      await service.clearChildData();
    }
  }
}
