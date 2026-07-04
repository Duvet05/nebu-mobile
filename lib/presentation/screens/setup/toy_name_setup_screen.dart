import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/constants/validation_rules.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/toy.dart';
import '../../providers/api_provider.dart';
import '../../providers/auth_provider.dart' as auth_provider;
import '../../providers/toy_provider.dart';
import '../../widgets/custom_input.dart';

class ToyNameSetupScreen extends ConsumerStatefulWidget {
  const ToyNameSetupScreen({super.key});

  @override
  ConsumerState<ToyNameSetupScreen> createState() => _ToyNameSetupScreenState();
}

class _ToyNameSetupScreenState extends ConsumerState<ToyNameSetupScreen> {
  static final RegExp _macAddressPattern = RegExp(
    r'^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$|^([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}$',
  );

  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isRegistering = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onNameChanged);
    _loadSavedName();
  }

  void _onNameChanged() {
    final valid = ValidationRules.validateToyName(_controller.text) == null;
    if (valid != _isValid) {
      setState(() => _isValid = valid);
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onNameChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadSavedName() async {
    final prefs = await ref.read(
      auth_provider.sharedPreferencesProvider.future,
    );
    if (!mounted) {
      return;
    }
    final savedName = prefs.getString(StorageKeys.setupToyName);
    _controller.text = (savedName != null && savedName.isNotEmpty)
        ? savedName
        : 'Nebu';
  }

  Future<void> _saveToyName() async {
    final prefs = await ref.read(
      auth_provider.sharedPreferencesProvider.future,
    );
    await prefs.setString(StorageKeys.setupToyName, _controller.text.trim());
  }

  /// Registrar dispositivo ESP32 en el backend
  /// Se ejecuta automáticamente al continuar con el setup si hay un Device ID guardado
  Future<bool> _registerDeviceIfNeeded() async {
    final prefs = await ref.read(
      auth_provider.sharedPreferencesProvider.future,
    );
    final logger = ref.read(loggerProvider);
    final deviceId = _nonBlank(prefs.getString(StorageKeys.currentDeviceId));
    final storedMacAddress = _nonBlank(
      prefs.getString(StorageKeys.setupMacAddress),
    );
    final macAddress = _validMacAddressOrNull(storedMacAddress);
    final deviceIdentifier = deviceId ?? macAddress;

    if (storedMacAddress != null && macAddress == null) {
      logger.w('[TOY_SETUP] Ignoring invalid stored MAC: $storedMacAddress');
    }

    // Si no hay Device ID ni MAC válida, el usuario saltó la configuración WiFi
    if (deviceIdentifier == null) {
      logger.d(
        '📱 [TOY_SETUP] No Device ID or valid MAC found, skipping device registration',
      );
      return true; // Continuar sin registrar
    }

    // Verificar que el usuario esté autenticado
    final authState = ref.read(auth_provider.authProvider);
    final user = authState.value;
    if (user == null) {
      logger.d('📱 [TOY_SETUP] User not authenticated, will save locally');
      return true; // El juguete se guardará localmente al final del setup
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      final toyName = _controller.text.trim();

      logger.i(
        '🚀 [TOY_SETUP] Registering device: $deviceIdentifier with name: $toyName',
      );

      // Crear el Toy en el backend
      await ref
          .read(toyProvider.notifier)
          .createToy(
            deviceId: deviceId,
            macAddress: macAddress,
            name: toyName,
            status: ToyStatus.active,
            model: 'Nebu',
            manufacturer: 'Nebu Technologies',
          );

      logger.i(
        '✅ [TOY_SETUP] Device registered successfully: $deviceIdentifier',
      );

      await _markDeviceRegistered(prefs);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('setup.toy_name.device_registered'.tr()),
            backgroundColor: context.colors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      return true;
    } on ConflictException catch (e) {
      logger.w(
        '⚠️ [TOY_SETUP] Device already registered, asking for transfer: $e',
      );

      if (!mounted) {
        return false;
      }

      final toyName = _controller.text.trim();
      final shouldTransfer = await _showTransferOwnerDialog(toyName);
      if (!shouldTransfer || !mounted) {
        return false;
      }

      try {
        final response = await ref
            .read(toyProvider.notifier)
            .assignToy(
              userId: user.id,
              deviceId: deviceId,
              macAddress: macAddress,
              toyName: toyName,
            );

        if (!response.success) {
          throw ConflictException(
            response.message ?? 'setup.toy_name.error_transfer_device'.tr(),
            statusCode: 409,
          );
        }

        if (response.toy == null) {
          await ref.read(toyProvider.notifier).loadMyToys();
        }

        await _markDeviceRegistered(prefs);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('setup.toy_name.device_transferred'.tr()),
              backgroundColor: context.colors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        logger.i(
          '✅ [TOY_SETUP] Device transferred successfully: $deviceIdentifier',
        );

        return true;
      } on Exception catch (assignError) {
        logger.e('❌ [TOY_SETUP] Error transferring device: $assignError');

        var errorMessage = 'setup.toy_name.error_transfer_device'.tr();
        if (assignError is AppException) {
          errorMessage = assignError.message;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: context.colors.error,
              action: SnackBarAction(
                label: 'common.retry'.tr(),
                textColor: context.colors.textOnFilled,
                onPressed: _registerDeviceIfNeeded,
              ),
            ),
          );
        }

        return false;
      }
    } on Exception catch (e) {
      logger.e('❌ [TOY_SETUP] Error registering device: $e');

      String errorMessage = 'setup.toy_name.error_registering_device'.tr();
      if (e is AppException) {
        errorMessage = e.message;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: context.colors.error,
            action: SnackBarAction(
              label: 'common.retry'.tr(),
              textColor: context.colors.textOnFilled,
              onPressed: _registerDeviceIfNeeded,
            ),
          ),
        );
      }

      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  Future<void> _markDeviceRegistered(SharedPreferences prefs) async {
    // Marcar que el dispositivo fue registrado en el backend
    await prefs.setBool(StorageKeys.setupDeviceRegistered, true);

    // Limpiar Device info de SharedPreferences (ya está registrado)
    await prefs.remove(StorageKeys.currentDeviceId);
    await prefs.remove(StorageKeys.setupMacAddress);
    ref
        .read(loggerProvider)
        .d('🗑️  [TOY_SETUP] Cleared Device info from local storage');
  }

  Future<bool> _showTransferOwnerDialog(String toyName) async {
    final displayName = toyName.isEmpty ? 'Nebu' : toyName;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('setup.toy_name.transfer_owner_title'.tr()),
        content: Text(
          'setup.toy_name.transfer_owner_message'.tr(
            namedArgs: {'toyName': displayName},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('setup.toy_name.transfer_owner_cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('setup.toy_name.transfer_owner_confirm'.tr()),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  String? _nonBlank(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String? _validMacAddressOrNull(String? value) {
    if (value == null) {
      return null;
    }
    return _macAddressPattern.hasMatch(value) ? value : null;
  }

  void _showSkipSetupDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('setup.connection.skip_dialog_title'.tr()),
        content: Text('setup.connection.skip_dialog_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              final nav = GoRouter.of(context);
              final navigator = Navigator.of(dialogContext);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool(StorageKeys.setupSkipped, true);
              if (!mounted) {
                return;
              }
              ref.invalidate(setupSkippedProvider);
              navigator.pop();
              nav.go(AppRoutes.home.path);
            },
            child: Text('setup.connection.skip_setup'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final colorScheme = theme.colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.gapMd,
                vertical: context.spacing.gapLg,
              ),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: MaterialLocalizations.of(context).backButtonTooltip,
                    child: GestureDetector(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: context.radius.tile,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildProgressIndicator(3, 7),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: context.constrainedPageEdgeInsets,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: context.spacing.titleBottomMargin),

                      // Use a scrollable view for the main content
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                'setup.toy_name.title'.tr(),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(
                                height: context.spacing.titleBottomMarginSm,
                              ),

                              Text(
                                'setup.toy_name.subtitle'.tr(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(
                                height: context.spacing.largePageBottomMargin,
                              ),

                              // Name input
                              CustomInput(
                                controller: _controller,
                                hint: 'setup.toy_name.hint'.tr(),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                textCapitalization: TextCapitalization.words,
                                validator: (value) =>
                                    ValidationRules.validateToyName(
                                      value,
                                    )?.tr(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: context.spacing.gapXl),

                      // Next button
                      Semantics(
                        button: true,
                        label: 'setup.toy_name.next'.tr(),
                        child: GestureDetector(
                          onTap: _isRegistering || !_isValid
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    await _saveToyName();
                                    final success =
                                        await _registerDeviceIfNeeded();
                                    if (success && context.mounted) {
                                      await context.push(
                                        AppRoutes.ageSetup.path,
                                      );
                                    }
                                  }
                                },
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _isValid ? 1.0 : 0.5,
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    context.colors.primary100,
                                    context.colors.primary,
                                  ],
                                ),
                                borderRadius: context.radius.panel,
                                boxShadow: [
                                  BoxShadow(
                                    color: context.colors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isRegistering
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                context.colors.textOnFilled,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        'setup.toy_name.next'.tr(),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color:
                                                  context.colors.textOnFilled,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: context.spacing.sectionTitleBottomMargin,
                      ),

                      Semantics(
                        button: true,
                        label: 'setup.connection.skip_setup'.tr(),
                        child: GestureDetector(
                          onTap: _showSkipSetupDialog,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: context.spacing.gapMd,
                            ),
                            child: Text(
                              'setup.connection.skip_setup'.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
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
    );
  }

  Widget _buildProgressIndicator(int current, int total) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(total, (index) {
      final isActive = index < current;
      return Container(
        margin: EdgeInsets.symmetric(horizontal: context.spacing.gapXxs),
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
