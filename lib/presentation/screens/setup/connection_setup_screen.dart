import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/api_provider.dart';

class ConnectionSetupScreen extends ConsumerStatefulWidget {
  const ConnectionSetupScreen({super.key});

  @override
  ConsumerState<ConnectionSetupScreen> createState() =>
      _ConnectionSetupScreenState();
}

class _ConnectionSetupScreenState extends ConsumerState<ConnectionSetupScreen>
    with SingleTickerProviderStateMixin {
  final _logger = Logger();
  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isBluetoothEnabled = false;
  StreamSubscription<fbp.BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<fbp.ScanResult>>? _scanSubscription;
  List<fbp.ScanResult> _scanResults = [];
  fbp.BluetoothDevice? _selectedDevice;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _stopScan();
    _adapterStateSubscription?.cancel();
    _scanSubscription?.cancel();
    _pulseController.dispose();
    _logger.close();
    super.dispose();
  }

  Future<void> _initializeBluetooth() async {
    _adapterStateSubscription = fbp.FlutterBluePlus.adapterState.listen((state) {
      _logger.d('Bluetooth adapter state changed: $state');
      if (mounted) {
        setState(() {
          _isBluetoothEnabled = state == fbp.BluetoothAdapterState.on;
        });
      }
    });

    final state = await fbp.FlutterBluePlus.adapterState.first;
    if (mounted) {
      setState(() {
        _isBluetoothEnabled = state == fbp.BluetoothAdapterState.on;
      });
    }
  }

  Future<void> _checkPermissionsAndStartScan() async {
    final hasPermissions = await _requestPermissions();
    if (hasPermissions && _isBluetoothEnabled) {
      await _startScan();
    }
  }

  Future<bool> _requestPermissions() async {
    try {
      _logger.i('Requesting Bluetooth permissions...');
      final permissions = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();
      final granted = permissions.values.every((status) => status.isGranted);
      _logger.i('All permissions granted: $granted');
      if (!granted && mounted) {
        _logger.w('Permissions denied, showing dialog');
        _showPermissionsDeniedSheet();
      }
      return granted;
    } on Exception catch (e) {
      _logger.e('Error requesting permissions: $e');
      return false;
    }
  }

  Future<void> _startScan() async {
    if (_isScanning) {
      return;
    }

    _logger.i('Starting Bluetooth scan...');
    setState(() {
      _isScanning = true;
      _scanResults = [];
      _selectedDevice = null;
    });

    try {
      await fbp.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );

      _scanSubscription = fbp.FlutterBluePlus.scanResults.listen((results) {
        final filteredResults = results
            .where((r) =>
                r.device.platformName.isNotEmpty &&
                (r.device.platformName.toLowerCase().contains('nebu') ||
                    r.device.platformName.toLowerCase().contains('esp32')))
            .toList();

        if (mounted) {
          setState(() => _scanResults = filteredResults);
        }
      });

      Future<void>.delayed(const Duration(seconds: 15), () {
        if (mounted) {
          _stopScan();
        }
      });
    } on Exception catch (e) {
      _logger.e('Error starting scan: $e');
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _stopScan() async {
    try {
      await fbp.FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      if (mounted) {
        setState(() => _isScanning = false);
      }
    } on Exception catch (e) {
      _logger.e('Error stopping scan: $e');
    }
  }

  Future<void> _connectToDevice(fbp.BluetoothDevice device) async {
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isConnecting = true);

    try {
      final esp32service = await ref.read(esp32WifiConfigServiceProvider.future);
      await esp32service.connectToESP32(device);

      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: context.colors.textOnFilled, size: 20),
              SizedBox(width: context.spacing.gapLg),
              Text('setup.connection.connected_to'.tr(args: [device.platformName])),
            ],
          ),
          backgroundColor: context.colors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: context.radius.button),
          margin: EdgeInsets.all(context.spacing.alertPadding),
        ),
      );

      setState(() => _selectedDevice = device);
    } on Exception catch (e) {
      _logger.e('Failed to connect: $e');
      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: context.colors.textOnFilled, size: 20),
              SizedBox(width: context.spacing.gapLg),
              Expanded(child: Text('setup.connection.connection_failed'.tr())),
            ],
          ),
          backgroundColor: context.colors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: context.radius.button),
          margin: EdgeInsets.all(context.spacing.alertPadding),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  void _showEnableBluetoothSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomSheet(
        icon: Icons.bluetooth_disabled_rounded,
        iconColor: context.colors.primary,
        title: 'setup.connection.enable_bluetooth_title'.tr(),
        description: 'setup.connection.enable_bluetooth_message'.tr(),
        primaryText: 'setup.connection.enable_bluetooth_title'.tr(),
        primaryOnPressed: () async {
          Navigator.pop(context);
          try {
            if (await fbp.FlutterBluePlus.isSupported) {
              await fbp.FlutterBluePlus.turnOn();
            }
          } on Exception catch (e) {
            _logger.e('Error turning on Bluetooth: $e');
          }
        },
        secondaryText: 'common.cancel'.tr(),
        secondaryOnPressed: () => Navigator.pop(context),
      ),
    );
  }

  void _showSkipSetupSheet() {
    showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          final textTheme = context.theme.textTheme;

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.all(context.spacing.pageMargin),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.grey700,
                    borderRadius: context.radius.checkbox,
                  ),
                ),
                SizedBox(height: context.spacing.panelPadding),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: context.radius.bottomSheet,
                  ),
                  child: Icon(
                    Icons.settings_rounded,
                    color: context.colors.primary,
                    size: 32,
                  ),
                ),
                SizedBox(height: context.spacing.titleBottomMargin),
                Text(
                  'setup.connection.setup_options'.tr(),
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.textNormal,
                  ),
                ),
                SizedBox(height: context.spacing.titleBottomMarginSm),
                Text(
                  'setup.connection.setup_options_desc'.tr(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: context.colors.grey400,
                  ),
                ),
                SizedBox(height: context.spacing.titleBottomMargin),

                // Option 1: Configure Locally
                _OptionCard(
                  icon: Icons.phone_android_rounded,
                  title: 'setup.connection.configure_locally'.tr(),
                  description: 'setup.connection.configure_locally_desc'.tr(),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.toyNameSetup.path);
                  },
                ),

                SizedBox(height: context.spacing.paragraphBottomMarginSm),

                // Option 2: Skip
                _OptionCard(
                  icon: Icons.arrow_forward_rounded,
                  title: 'setup.connection.skip_setup'.tr(),
                  description: 'setup.connection.skip_setup_desc'.tr(),
                  isSecondary: true,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.home.path);
                  },
                ),

                SizedBox(height: context.spacing.sectionTitleBottomMargin),
              ],
            ),
          );
        });
  }

  void _showPermissionsDeniedSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomSheet(
        icon: Icons.security_rounded,
        iconColor: context.colors.warning,
        title: 'setup.connection.permissions_required_title'.tr(),
        description:
            'setup.connection.permissions_denied_desc'.tr(),
        primaryText: 'setup.connection.open_settings'.tr(),
        primaryOnPressed: () {
          Navigator.pop(context);
          openAppSettings();
        },
        secondaryText: 'common.cancel'.tr(),
        secondaryOnPressed: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;
    final colorScheme = context.theme.colorScheme;
    final canProceed = _selectedDevice != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.spacing.gapMd, vertical: context.spacing.gapLg),
              child: Row(
                children: [
                  _BackButton(onPressed: () => context.pop()),
                  const Spacer(),
                  const _StepIndicator(currentStep: 1, totalSteps: 7),
                  const Spacer(),
                  const SizedBox(width: 44), // Balance
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: context.spacing.pageEdgeInsets,
                child: Column(
                  children: [
                    SizedBox(height: context.spacing.titleBottomMargin),

                    // Title section
                    Text(
                      'setup.connection.title'.tr(),
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: context.spacing.titleBottomMarginSm),
                    Text(
                      _isScanning
                          ? 'setup.connection.searching'.tr()
                          : 'setup.connection.subtitle'.tr(),
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    SizedBox(height: context.spacing.largePageBottomMargin),

                    // Main content area
                    Expanded(
                      child: _isScanning
                          ? _buildScanningView()
                          : _scanResults.isEmpty
                              ? _buildEmptyState()
                              : _buildDevicesList(),
                    ),

                    // Bottom buttons
                    _PrimaryButton(
                      text: _isScanning
                          ? 'setup.connection.scanning'.tr()
                          : canProceed
                              ? 'common.continue'.tr()
                              : 'setup.connection.start_scan'.tr(),
                      isLoading: _isScanning,
                      onPressed: () {
                        if (_isScanning) {
                          return;
                        }
                        if (canProceed) {
                          context.push(AppRoutes.wifiSetup.path);
                        } else if (!_isBluetoothEnabled) {
                          _showEnableBluetoothSheet();
                        } else {
                          _checkPermissionsAndStartScan();
                        }
                      },
                    ),

                    SizedBox(height: context.spacing.sectionTitleBottomMargin),

                    GestureDetector(
                      onTap: _showSkipSetupSheet,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: context.spacing.gapMd),
                        child: Text(
                          'setup.connection.skip_for_now'.tr(),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: context.spacing.panelPadding),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningView() {
    final textTheme = context.theme.textTheme;
    final colorScheme = context.theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: context.radius.largeIcon,
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.15),
                      borderRadius: context.radius.button,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.bluetooth_searching_rounded,
                        size: 36,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: context.spacing.gapXxl),
          Text(
            'setup.connection.looking_for_devices'.tr(),
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.spacing.gapMd),
          Text(
            'setup.connection.make_sure_on'.tr(),
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final textTheme = context.theme.textTheme;
    final colorScheme = context.theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: context.radius.largeIcon,
            ),
            child: Icon(
              Icons.bluetooth_rounded,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: context.spacing.gapXxl),
          Text(
            'setup.connection.ready_to_connect'.tr(),
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.spacing.gapMd),
          Text(
            'setup.connection.start_scan_hint'.tr(),
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList() {
    final textTheme = context.theme.textTheme;
    final colorScheme = context.theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'setup.connection.available_devices'.tr(),
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(width: context.spacing.gapMd),
            Container(
              padding: EdgeInsets.symmetric(horizontal: context.spacing.gapMd, vertical: context.spacing.gapXxs),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: context.radius.tile,
              ),
              child: Text(
                '${_scanResults.length}',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.spacing.gapXl),
        Expanded(
          child: ListView.builder(
            itemCount: _scanResults.length,
            itemBuilder: (context, index) {
              final result = _scanResults[index];
              final device = result.device;
              final isSelected = _selectedDevice?.remoteId == device.remoteId;
              final isConnecting = _isConnecting && isSelected;

              return _DeviceCard(
                name: device.platformName.isNotEmpty
                    ? device.platformName
                    : 'setup.connection.unknown_device'.tr(),
                signal: result.rssi,
                isSelected: isSelected,
                isConnecting: isConnecting,
                onTap: _isConnecting ? null : () => _connectToDevice(device),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============ Reusable Components ============

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: context.radius.tile,
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(totalSteps, (index) {
          final isActive = index < currentStep;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? context.colors.primary
                  : context.colors.primary.withValues(alpha: 0.2),
              borderRadius: context.radius.checkbox,
            ),
          );
        }),
      );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.colors.primary100, context.colors.primary],
          ),
          borderRadius: context.radius.panel,
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(context.colors.textOnFilled),
                  ),
                )
              : Text(
                  text,
                  style: textTheme.titleMedium?.copyWith(
                    color: context.colors.textOnFilled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.name,
    required this.signal,
    required this.isSelected,
    required this.isConnecting,
    this.onTap,
  });
  final String name;
  final int signal;
  final bool isSelected;
  final bool isConnecting;
  final VoidCallback? onTap;

  IconData _getSignalIcon() {
    if (signal >= -50) {
      return Icons.signal_cellular_4_bar_rounded;
    }
    if (signal >= -70) {
      return Icons.signal_cellular_alt_rounded;
    }
    return Icons.signal_cellular_alt_1_bar_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;
    final colorScheme = context.theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: context.spacing.gapLg),
        padding: EdgeInsets.all(context.spacing.gapXl),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primary.withValues(alpha: 0.08)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: context.radius.panel,
          border: Border.all(
            color:
                isSelected ? context.colors.primary : colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.primary.withValues(alpha: 0.15)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: context.radius.panel,
              ),
              child: isConnecting
                  ? Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.colors.primary,
                          ),
                        ),
                      ),
                    )
                  : Icon(
                      Icons.bluetooth_rounded,
                      color: isSelected
                          ? context.colors.primary
                          : colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
            ),
            SizedBox(width: context.spacing.gapXl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? context.colors.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: context.spacing.gapXs),
                  Row(
                    children: [
                      Icon(
                        _getSignalIcon(),
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: context.spacing.gapXs),
                      Text(
                        '$signal dBm',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected && !isConnecting)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: context.colors.textOnFilled,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  const _BottomSheet({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.primaryText,
    required this.primaryOnPressed,
    required this.secondaryText,
    required this.secondaryOnPressed,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String primaryText;
  final VoidCallback primaryOnPressed;
  final String secondaryText;
  final VoidCallback secondaryOnPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.all(context.spacing.gapXxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.grey700,
              borderRadius: context.radius.checkbox,
            ),
          ),
          SizedBox(height: context.spacing.gapXxl),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: context.radius.bottomSheet,
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          SizedBox(height: context.spacing.gapXxl),
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.textNormal,
            ),
          ),
          SizedBox(height: context.spacing.gapMd),
          Text(
            description,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: context.colors.grey400,
              height: 1.4,
            ),
          ),
          SizedBox(height: context.spacing.gapXxl),
          GestureDetector(
            onTap: primaryOnPressed,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: context.radius.panel,
              ),
              child: Center(
                child: Text(
                  primaryText,
                  style: textTheme.titleMedium?.copyWith(
                    color: context.colors.textOnFilled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: context.spacing.gapLg),
          GestureDetector(
            onTap: secondaryOnPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: context.spacing.gapLg),
              child: Text(
                secondaryText,
                style: textTheme.bodyMedium?.copyWith(
                  color: context.colors.grey400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.isSecondary = false,
  });
  final IconData icon;
  final String title;
  final String description;
  final bool isSecondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.spacing.gapXl),
        decoration: BoxDecoration(
          color: isSecondary
              ? context.colors.grey900
              : context.colors.primary.withValues(alpha: 0.08),
          borderRadius: context.radius.panel,
          border: Border.all(
            color: isSecondary
                ? context.colors.grey700
                : context.colors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSecondary
                    ? context.colors.grey800
                    : context.colors.primary.withValues(alpha: 0.15),
                borderRadius: context.radius.tile,
              ),
              child: Icon(
                icon,
                color: isSecondary ? context.colors.grey400 : context.colors.primary,
                size: 22,
              ),
            ),
            SizedBox(width: context.spacing.gapXl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSecondary
                          ? context.colors.grey300
                          : context.colors.primary,
                    ),
                  ),
                  SizedBox(height: context.spacing.gapXxs),
                  Text(
                    description,
                    style: textTheme.bodySmall?.copyWith(
                      color: context.colors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: context.colors.grey500,
            ),
          ],
        ),
      ),
    );
  }
}
