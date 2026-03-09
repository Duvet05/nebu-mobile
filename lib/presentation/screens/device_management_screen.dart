import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/toy.dart';
import '../providers/toy_provider.dart';

class DeviceManagementScreen extends ConsumerStatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  ConsumerState<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends ConsumerState<DeviceManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(toyProvider.notifier).loadMyToys();
    });
  }

  Future<void> _refreshDevices() async {
    await ref.read(toyProvider.notifier).loadMyToys();
  }

  Future<void> _deleteDevice(String toyId) async {
    try {
      await ref.read(toyProvider.notifier).deleteToy(toyId);
      if (mounted) {
        context.showInfoSnackBar('device_management.remove_success'.tr());
      }
    } on Exception {
      if (mounted) {
        context.showInfoSnackBar('device_management.remove_error'.tr());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final toysAsync = ref.watch(toyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('device_management.title'.tr()),
        actions: [
          if (!toysAsync.isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshDevices,
            ),
        ],
      ),
      body: toysAsync.when(
        data: (toys) {
          if (toys.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.devices_other,
                    size: 64,
                    color: theme.disabledColor,
                  ),
                  SizedBox(height: context.spacing.sectionTitleBottomMargin),
                  Text(
                    'device_management.no_devices'.tr(),
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshDevices,
            child: ListView.builder(
              padding: EdgeInsets.all(context.spacing.alertPadding),
              itemCount: toys.length,
              itemBuilder: (context, index) {
                final toy = toys[index];
                return _DeviceCard(
                  toy: toy,
                  theme: theme,
                  onDelete: () => _deleteDevice(toy.id),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => RefreshIndicator(
          onRefresh: _refreshDevices,
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
                    'device_management.error_loading'.tr(),
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
                      borderRadius: context.radius.alert,
                      border: Border.all(
                        color: theme.colorScheme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'device_management.error_loading'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: context.spacing.panelPadding),
                  ElevatedButton.icon(
                    onPressed: _refreshDevices,
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
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.toy,
    required this.theme,
    required this.onDelete,
  });

  final Toy toy;
  final ThemeData theme;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isOnline = toy.status == ToyStatus.active;

    return Card(
      margin: EdgeInsets.only(bottom: context.spacing.paragraphBottomMarginSm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isOnline
              ? context.colors.success.withValues(alpha: 0.1)
              : context.colors.grey500.withValues(alpha: 0.1),
          child: Icon(
            Icons.smart_toy,
            color: isOnline ? context.colors.success : context.colors.grey500,
          ),
        ),
        title: Text(toy.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (toy.model != null) Text('device_management.model'.tr(args: [toy.model ?? ''])),
            Text('device_management.status'.tr(args: [toy.status.name])),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: context.colors.error),
          onPressed: () async {
            final confirmed = await showConfirmDialog(
              context,
              title: 'device_management.remove_title'.tr(),
              content: 'device_management.remove_confirm'.tr(args: [toy.name]),
              destructive: true,
            );
            if (confirmed) {
              onDelete();
            }
          },
        ),
      ),
    );
  }
}
