import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/services/wifi_service.dart';
import 'custom_button.dart';

/// Modal bottom sheet for scanning and selecting available WiFi networks.
class WifiNetworksSheet extends StatefulWidget {
  const WifiNetworksSheet({
    required this.wifiService,
    required this.onNetworkSelected,
    super.key,
  });

  final WiFiService wifiService;
  final void Function(String) onNetworkSelected;

  @override
  State<WifiNetworksSheet> createState() => _WifiNetworksSheetState();
}

class _WifiNetworksSheetState extends State<WifiNetworksSheet> {
  bool _isLoading = true;
  List<WiFiNetwork> _networks = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _scanNetworks();
  }

  Future<void> _scanNetworks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final networks = await widget.wifiService.scanNetworks();
      if (mounted) {
        setState(() {
          _networks = networks;
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.gapXxl, vertical: context.spacing.gapXxl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'setup.wifi.scan_networks'.tr(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: context.colors.textNormal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _scanNetworks,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          SizedBox(height: context.spacing.gapXxl),
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(context.spacing.gapXxl),
                child: const CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Padding(
              padding: EdgeInsets.all(context.spacing.gapXxl),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: context.colors.error,
                    size: 48,
                  ),
                  SizedBox(height: context.spacing.gapXl),
                  Text(
                    'setup.wifi.scan_error'.tr(),
                    style: theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: context.spacing.gapXxl),
                  CustomButton(
                    text: 'common.retry'.tr(),
                    onPressed: _scanNetworks,
                  ),
                ],
              ),
            )
          else if (_networks.isEmpty)
            Padding(
              padding: EdgeInsets.all(context.spacing.gapXxl),
              child: Text(
                'setup.wifi.no_networks_found'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _networks.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final network = _networks[index];
                  return ListTile(
                    leading: const Icon(Icons.wifi),
                    title: Text(network.ssid),
                    subtitle: Text(
                      'setup.wifi.signal_info'.tr(args: ['${network.rssi}']),
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      widget.onNetworkSelected(network.ssid);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          SizedBox(height: context.spacing.gapXl),
          CustomButton(
            text: 'common.cancel'.tr(),
            onPressed: () => Navigator.of(context).pop(),
            variant: ButtonVariant.text,
          ),
        ],
      ),
    );
  }
}
