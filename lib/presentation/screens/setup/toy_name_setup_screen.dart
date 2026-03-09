import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/toy.dart';
import '../../providers/api_provider.dart';
import '../../providers/auth_provider.dart' as auth_provider;

class ToyNameSetupScreen extends ConsumerStatefulWidget {
  const ToyNameSetupScreen({super.key});

  @override
  ConsumerState<ToyNameSetupScreen> createState() => _ToyNameSetupScreenState();
}

class _ToyNameSetupScreenState extends ConsumerState<ToyNameSetupScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _loadSavedName();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSavedName() async {
    final prefs = await ref.read(
      auth_provider.sharedPreferencesProvider.future,
    );
    final savedName = prefs.getString(StorageKeys.setupToyName);
    if (savedName != null && savedName.isNotEmpty) {
      _controller.text = savedName;
    }
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
    final deviceId = prefs.getString(StorageKeys.currentDeviceId);

    // Si no hay Device ID guardado, el usuario saltó la configuración WiFi
    if (deviceId == null || deviceId.isEmpty) {
      ref
          .read(loggerProvider)
          .d('📱 [TOY_SETUP] No Device ID found, skipping device registration');
      return true; // Continuar sin registrar
    }

    // Verificar que el usuario esté autenticado
    final authState = ref.read(auth_provider.authProvider);
    final user = authState.value;
    if (user == null) {
      ref
          .read(loggerProvider)
          .d('📱 [TOY_SETUP] User not authenticated, will save locally');
      return true; // El juguete se guardará localmente al final del setup
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      final toyService = ref.read(toyServiceProvider);
      final toyName = _controller.text.trim();

      ref
          .read(loggerProvider)
          .i(
            '🚀 [TOY_SETUP] Registering device: $deviceId with name: $toyName',
          );

      // Crear el Toy en el backend
      await toyService.createToy(
        iotDeviceId: deviceId,
        name: toyName,
        userId: user.id,
        status: ToyStatus.active,
        model: 'ESP32', // Modelo detectado del Device ID
        manufacturer: 'NEBU',
      );

      ref
          .read(loggerProvider)
          .i('✅ [TOY_SETUP] Device registered successfully: $deviceId');

      // Marcar que el dispositivo fue registrado en el backend
      await prefs.setBool(StorageKeys.setupDeviceRegistered, true);

      // Limpiar el Device ID de SharedPreferences (ya está registrado)
      await prefs.remove(StorageKeys.currentDeviceId);
      ref
          .read(loggerProvider)
          .d('🗑️  [TOY_SETUP] Cleared Device ID from local storage');

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
    } on Exception catch (e) {
      ref.read(loggerProvider).e('❌ [TOY_SETUP] Error registering device: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('setup.toy_name.error_registering_device'.tr()),
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

  void _showSkipSetupDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('setup.connection.skip_dialog_title'.tr()),
        content: Text('setup.connection.skip_dialog_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.home.path);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.textOnFilled,
            ),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: context.radius.tile,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
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
                padding: context.spacing.pageEdgeInsets,
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
                                style:
                                    theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(
                                  height: context.spacing.titleBottomMarginSm),

                              Text(
                                'setup.toy_name.subtitle'.tr(),
                                style:
                                    theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(
                                  height:
                                      context.spacing.largePageBottomMargin),

                              // Name input
                              TextFormField(
                                controller: _controller,
                                style: theme.textTheme.titleMedium,
                                textCapitalization:
                                    TextCapitalization.words,
                                decoration: InputDecoration(
                                  hintText: 'setup.toy_name.hint'.tr(),
                                  hintStyle: TextStyle(
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                  filled: true,
                                  fillColor: colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                                  border: OutlineInputBorder(
                                    borderRadius: context.radius.input,
                                    borderSide: BorderSide(
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: context.radius.input,
                                    borderSide: BorderSide(
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: context.radius.input,
                                    borderSide: BorderSide(
                                      color: context.colors.primary,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(20),
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'setup.toy_name.validation_empty'
                                        .tr();
                                  }
                                  if (value.trim().length < 2) {
                                    return 'setup.toy_name.validation_short'
                                        .tr();
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Next button
                      GestureDetector(
                        onTap: _isRegistering
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  await _saveToyName();
                                  final success =
                                      await _registerDeviceIfNeeded();
                                  if (success && context.mounted) {
                                    await context
                                        .push(AppRoutes.ageSetup.path);
                                  }
                                }
                              },
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
                                color: context.colors.primary
                                    .withValues(alpha: 0.3),
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
                                      color: context.colors.textOnFilled,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      SizedBox(
                          height: context.spacing.sectionTitleBottomMargin),

                      GestureDetector(
                        onTap: _showSkipSetupDialog,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'setup.connection.skip_setup'.tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
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
