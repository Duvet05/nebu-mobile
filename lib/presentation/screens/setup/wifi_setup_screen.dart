import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart' as logger;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/validation_rules.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/esp32_wifi_config_service.dart';
import '../../../data/services/wifi_qr_parser.dart';
import '../../../data/services/wifi_service.dart';
import '../../providers/api_provider.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/setup_widgets.dart';
import '../../widgets/wifi_networks_sheet.dart';

class WifiSetupScreen extends ConsumerStatefulWidget {
  const WifiSetupScreen({super.key});

  @override
  ConsumerState<WifiSetupScreen> createState() => _WifiSetupScreenState();
}

const _kConnectionTimeout = Duration(seconds: 45);
const _kNavigationDelay = Duration(seconds: 1);
const _kSnackBarDuration = Duration(seconds: 2);
const _kSnackBarDurationLong = Duration(seconds: 5);

final _logger = logger.Logger();

class _WifiSetupScreenState extends ConsumerState<WifiSetupScreen> {
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isConnecting = false;
  StreamSubscription<ESP32WifiStatus>? _statusSubscription;
  Timer? _timeoutTimer;
  final _networkInfo = NetworkInfo();

  @override
  void initState() {
    super.initState();
    _subscribeToWifiStatus();
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    _statusSubscription?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  // ─── Status Stream ───

  Future<void> _subscribeToWifiStatus() async {
    final esp32service = await ref.read(esp32WifiConfigServiceProvider.future);
    if (!mounted) {
      return;
    }

    _statusSubscription = esp32service.statusStream.listen(
      (status) {
        if (!mounted) {
          return;
        }

        final messenger = ScaffoldMessenger.of(context);

        switch (status) {
          case ESP32WifiStatus.idle:
            break;

          case ESP32WifiStatus.connecting:
            messenger.showSnackBar(
              SnackBar(
                content: Text('setup.wifi.status_connecting'.tr()),
                backgroundColor: context.colors.info,
                duration: _kSnackBarDuration,
              ),
            );

          case ESP32WifiStatus.reconnecting:
            messenger.showSnackBar(
              SnackBar(
                content: Text('setup.wifi.status_reconnecting'.tr()),
                backgroundColor: context.colors.warning,
                duration: _kSnackBarDuration,
              ),
            );

          case ESP32WifiStatus.connected:
            _timeoutTimer?.cancel();
            setState(() => _isConnecting = false);

            messenger.showSnackBar(
              SnackBar(
                content: Text('setup.wifi.status_connected'.tr()),
                backgroundColor: context.colors.success,
              ),
            );

            unawaited(
              Future<void>.delayed(_kNavigationDelay, () {
                if (mounted) {
                  context.push(AppRoutes.toyNameSetup.path);
                }
              }),
            );

          case ESP32WifiStatus.failed:
            _timeoutTimer?.cancel();
            setState(() => _isConnecting = false);

            messenger.showSnackBar(
              SnackBar(
                content: Text('setup.wifi.status_failed'.tr()),
                backgroundColor: context.colors.error,
                duration: _kSnackBarDurationLong,
                action: SnackBarAction(
                  label: 'setup.wifi.retry'.tr(),
                  textColor: context.colors.textOnFilled,
                  onPressed: _connectToWifi,
                ),
              ),
            );
        }
      },
      onError: (Object error) {
        _logger.e('WiFi status stream error: $error');
        if (!mounted) {
          return;
        }

        _timeoutTimer?.cancel();
        if (_isConnecting) {
          setState(() => _isConnecting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('setup.wifi.error_status_stream'.tr()),
              backgroundColor: context.colors.error,
              duration: _kSnackBarDurationLong,
            ),
          );
        }
      },
      onDone: () {
        if (!mounted) {
          return;
        }

        _timeoutTimer?.cancel();
        if (_isConnecting) {
          setState(() => _isConnecting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('setup.wifi.error_ble_disconnected'.tr()),
              backgroundColor: context.colors.error,
              duration: _kSnackBarDurationLong,
            ),
          );
        }
      },
    );
  }

  // ─── Actions ───

  Future<void> _scanQrCode() async {
    final result = await context.push<String>(AppRoutes.qrScanner.path);
    if (result != null && mounted) {
      final parsed = WiFiQrParser.parse(result);
      if (parsed != null) {
        setState(() {
          _ssidController.text = parsed.ssid;
          _passwordController.text = parsed.password;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('qr_scanner.wifi_loaded'.tr())));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('qr_scanner.invalid_wifi_qr'.tr())),
        );
      }
    }
  }

  Future<void> _getCurrentWifi() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      try {
        final wifiName = await _networkInfo.getWifiName();
        if (wifiName != null && mounted) {
          setState(() {
            _ssidController.text = wifiName.replaceAll('"', '');
          });
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('qr_scanner.wifi_name_error'.tr())),
          );
        }
      } on Exception {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('setup.wifi.error_generic'.tr())),
          );
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('qr_scanner.location_permission_required'.tr())),
      );
    }
  }

  Future<void> _showWifiNetworksSheet() async {
    final esp32Service = await ref.read(esp32WifiConfigServiceProvider.future);
    if (!mounted) {
      return;
    }

    final wifiService = WiFiService(
      logger: logger.Logger(),
      esp32WifiConfigService: esp32Service,
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => WifiNetworksSheet(
        wifiService: wifiService,
        onNetworkSelected: (ssid) {
          setState(() => _ssidController.text = ssid);
        },
      ),
    );
  }

  Future<void> _connectToWifi() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isConnecting) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final colors = context.colors;

    setState(() => _isConnecting = true);

    try {
      final service = await ref.read(esp32WifiConfigServiceProvider.future);

      final result = await service.sendWifiCredentials(
        ssid: _ssidController.text.trim(),
        password: _passwordController.text,
      );

      if (result.success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('setup.wifi.credentials_sent'.tr()),
            backgroundColor: colors.success,
          ),
        );

        _timeoutTimer = Timer(_kConnectionTimeout, () {
          if (_isConnecting && mounted) {
            _showTimeoutDialog();
          }
        });
      } else {
        throw Exception(result.message);
      }
    } on Exception catch (e) {
      final errorMsg = e.toString().toLowerCase();

      String translationKey;
      Color snackColor;
      if (errorMsg.contains('disconnected') ||
          errorMsg.contains('connection') ||
          errorMsg.contains('not connected')) {
        translationKey = 'setup.wifi.error_ble_disconnected';
        snackColor = colors.error;
      } else if (errorMsg.contains('timeout') ||
          errorMsg.contains('timed out')) {
        translationKey = 'setup.wifi.error_ble_timeout';
        snackColor = colors.warning;
      } else {
        translationKey = 'setup.wifi.error_send_credentials';
        snackColor = colors.error;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(translationKey.tr()),
          backgroundColor: snackColor,
          duration: _kSnackBarDurationLong,
        ),
      );

      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  Future<void> _showTimeoutDialog() async {
    final shouldContinue = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('setup.wifi.timeout_dialog_title'.tr()),
        content: Text('setup.wifi.timeout_dialog_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('setup.wifi.keep_waiting'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('setup.wifi.continue_anyway'.tr()),
          ),
        ],
      ),
    );

    if ((shouldContinue ?? false) && mounted) {
      setState(() => _isConnecting = false);
      await context.push(AppRoutes.toyNameSetup.path);
    }
  }

  void _cancelConnection() {
    _timeoutTimer?.cancel();
    setState(() => _isConnecting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('setup.wifi.connection_cancelled'.tr()),
        backgroundColor: context.colors.warning,
      ),
    );
  }

  void _skipWifiSetup() {
    context.push(AppRoutes.toyNameSetup.path);
  }

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return PopScope(
      canPop: !_isConnecting,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        if (_isConnecting && context.mounted) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text('setup.wifi.cancel_dialog_title'.tr()),
              content: Text('setup.wifi.cancel_dialog_message'.tr()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text('common.no'.tr()),
                ),
                TextButton(
                  onPressed: () {
                    _timeoutTimer?.cancel();
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: Text('common.yes'.tr()),
                ),
              ],
            ),
          );

          if ((shouldPop ?? false) && context.mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              const SetupHeader(currentStep: 2, totalSteps: 7),

              Expanded(
                child: Padding(
                  padding: context.spacing.pageEdgeInsets,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: context.spacing.titleBottomMargin),

                        Text(
                          'setup.wifi.title'.tr(),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.spacing.titleBottomMarginSm),
                        Text(
                          'setup.wifi.subtitle'.tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: context.spacing.largePageBottomMargin),

                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildQuickActions(theme),
                                SizedBox(height: context.spacing.gapLg),
                                _buildHotspotHint(),
                                SizedBox(height: context.spacing.gapXl),
                                _buildSsidInput(),
                                SizedBox(height: context.spacing.gapXxl),
                                _buildPasswordInput(),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: context.spacing.gapXl),

                        SetupPrimaryButton(
                          text: 'setup.wifi.connect_button'.tr(),
                          isLoading: _isConnecting,
                          onPressed: _connectToWifi,
                        ),

                        SizedBox(
                          height: context.spacing.sectionTitleBottomMargin,
                        ),

                        Semantics(
                          button: true,
                          label: _isConnecting
                              ? 'setup.wifi.cancel_button'.tr()
                              : 'setup.wifi.skip_button'.tr(),
                          child: GestureDetector(
                            onTap: _isConnecting
                                ? _cancelConnection
                                : _skipWifiSetup,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: context.spacing.gapMd,
                              ),
                              child: Text(
                                _isConnecting
                                    ? 'setup.wifi.cancel_button'.tr()
                                    : 'setup.wifi.skip_button'.tr(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: _isConnecting
                                      ? context.colors.error
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: context.spacing.panelPadding),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Sub-widgets ───

  Widget _buildHotspotHint() => Row(
    children: [
      Icon(
        Icons.info_outline,
        size: 14,
        color: context.theme.colorScheme.onSurfaceVariant.withValues(
          alpha: 0.7,
        ),
      ),
      SizedBox(width: context.spacing.gapSm),
      Expanded(
        child: Text(
          'setup.wifi.hotspot_hint'.tr(),
          style: context.theme.textTheme.bodySmall?.copyWith(
            color: context.theme.colorScheme.onSurfaceVariant.withValues(
              alpha: 0.7,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildQuickActions(ThemeData theme) => Wrap(
    alignment: WrapAlignment.spaceEvenly,
    spacing: context.spacing.gapMd,
    runSpacing: context.spacing.gapMd,
    children: [
      _QuickActionButton(
        icon: Icons.qr_code_scanner,
        label: 'setup.wifi.qr_scan_label'.tr(),
        onPressed: _scanQrCode,
      ),
      _QuickActionButton(
        icon: Icons.wifi,
        label: 'setup.wifi.current_wifi_label'.tr(),
        onPressed: _getCurrentWifi,
      ),
      _QuickActionButton(
        icon: Icons.wifi_find,
        label: 'setup.wifi.scan_networks'.tr(),
        onPressed: _showWifiNetworksSheet,
      ),
    ],
  );

  Widget _buildSsidInput() => CustomInput(
    controller: _ssidController,
    hint: 'setup.wifi.ssid_hint'.tr(),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'setup.wifi.validation_ssid_empty'.tr();
      }
      if (value.trim().length > ValidationRules.wifiSsidMaxBytes) {
        return 'setup.wifi.validation_ssid_too_long'.tr();
      }
      if (value.contains('\n') || value.contains('\r')) {
        return 'setup.wifi.validation_ssid_invalid_chars'.tr();
      }
      return null;
    },
  );

  Widget _buildPasswordInput() => CustomInput(
    controller: _passwordController,
    hint: 'setup.wifi.password_hint'.tr(),
    obscureText: true,
    validator: (value) {
      if (value != null &&
          value.isNotEmpty &&
          value.length < ValidationRules.wifiPasswordMinLength) {
        return 'setup.wifi.validation_password_too_short'.tr();
      }
      if (value != null &&
          value.length > ValidationRules.wifiPasswordMaxLength) {
        return 'setup.wifi.validation_password_too_long'.tr();
      }
      return null;
    },
  );

}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: context.radius.input,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.gapXl,
            vertical: context.spacing.gapLg,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: context.radius.input,
            border: Border.all(color: colorScheme.outline),
          ),
          child: Column(
            children: [
              Icon(icon, color: context.colors.primary, size: 28),
              SizedBox(height: context.spacing.gapXs),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
