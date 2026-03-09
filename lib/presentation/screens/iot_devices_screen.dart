import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/iot_device.dart';
import '../providers/iot_provider.dart';

class IoTDevicesScreen extends ConsumerWidget {
  const IoTDevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iotDevicesState = ref.watch(iotDevicesProvider);
    final colorScheme = context.theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('iot_devices.title'.tr()),
      ),
      body: iotDevicesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : iotDevicesState.error != null
              ? Center(
                  child: Text(
                    'Error: ${iotDevicesState.error}',
                    style: TextStyle(color: context.colors.error),
                  ),
                )
              : iotDevicesState.devices.isEmpty
                  ? Center(
                      child: Text(
                        'iot_devices.no_devices'.tr(),
                        style: TextStyle(fontSize: 18, color: context.colors.grey400),
                      ),
                    )
                  : ListView.builder(
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
                              child: Icon(Icons.devices_other, color: colorScheme.primary),
                            ),
                            title: Text(
                              device.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Builder(
                              builder: (context) {
                                final deviceType = device.deviceType?.toString().split('.').last ?? 'toy_settings.unknown'.tr();
                                return Text(
                                  'ID: ${device.id}\nType: $deviceType',
                                  style: TextStyle(color: context.colors.grey400),
                                );
                              },
                            ),
                            trailing: Icon(
                              Icons.circle,
                              color: device.status == DeviceStatus.online ? context.colors.success : context.colors.error,
                              size: 12,
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(iotDevicesProvider.notifier).fetchUserDevices(),
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.refresh, color: context.colors.textOnFilled),
      ),
    );
  }
}
