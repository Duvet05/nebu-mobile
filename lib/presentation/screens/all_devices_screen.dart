import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/iot_device.dart';
import '../../data/models/toy.dart';
import '../providers/iot_provider.dart';
import '../providers/toy_provider.dart';

class AllDevicesScreen extends ConsumerStatefulWidget {
  const AllDevicesScreen({super.key});

  @override
  ConsumerState<AllDevicesScreen> createState() => _AllDevicesScreenState();
}

class _AllDevicesScreenState extends ConsumerState<AllDevicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(toyProvider.notifier).loadMyToys();
      ref.read(iotDevicesProvider.notifier).fetchUserDevices();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshDevices() async {
    await Future.wait([
      ref.read(toyProvider.notifier).loadMyToys(),
      ref.read(iotDevicesProvider.notifier).fetchUserDevices(),
    ]);
  }

  Future<void> _deleteToy(String toyId) async {
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('all_devices.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDevices,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'all_devices.tab_toys'.tr(), icon: const Icon(Icons.smart_toy)),
            Tab(text: 'all_devices.tab_iot'.tr(), icon: const Icon(Icons.router)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildToysTab(theme),
          _buildIoTDevicesTab(theme),
        ],
      ),
    );
  }

  Widget _buildToysTab(ThemeData theme) {
    final toysAsync = ref.watch(toyProvider);

    return toysAsync.when(
      data: (toys) {
        if (toys.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.smart_toy,
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
              return _ToyCard(
                toy: toy,
                theme: theme,
                onDelete: () => _deleteToy(toy.id),
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
                    borderRadius: context.radius.tile,
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
    );
  }

  Widget _buildIoTDevicesTab(ThemeData theme) {
    final iotDevicesState = ref.watch(iotDevicesProvider);
    final colorScheme = theme.colorScheme;

    if (iotDevicesState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (iotDevicesState.error != null) {
      return Center(
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
              'all_devices.error_iot'.tr(),
              style: TextStyle(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.panelPadding),
            ElevatedButton.icon(
              onPressed: _refreshDevices,
              icon: const Icon(Icons.refresh),
              label: Text('common.retry'.tr()),
            ),
          ],
        ),
      );
    }

    if (iotDevicesState.devices.isEmpty) {
      return Center(
        child: Text(
          'all_devices.no_iot_devices'.tr(),
          style: TextStyle(fontSize: 18, color: context.colors.grey500),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshDevices,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: iotDevicesState.devices.length,
        itemBuilder: (context, index) {
          final device = iotDevicesState.devices[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: context.radius.tile,
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(context.spacing.alertPadding),
              leading: CircleAvatar(
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(Icons.router, color: colorScheme.primary),
              ),
              title: Text(
                device.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'ID: ${device.id}\nType: ${device.deviceType?.toString().split('.').last ?? 'toy_settings.unknown'.tr()}',
                style: TextStyle(color: context.colors.grey400),
              ),
              trailing: Icon(
                Icons.circle,
                color: device.status == DeviceStatus.online
                    ? context.colors.success
                    : context.colors.error,
                size: 12,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ToyCard extends StatelessWidget {
  const _ToyCard({
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
