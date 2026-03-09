import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/toy.dart';
import '../providers/toy_provider.dart';
import '../widgets/esp32_audio_controls.dart';

class ToySettingsScreen extends ConsumerStatefulWidget {
  const ToySettingsScreen({required this.toy, super.key});

  final Toy toy;

  @override
  ConsumerState<ToySettingsScreen> createState() => _ToySettingsScreenState();
}

class _ToySettingsScreenState extends ConsumerState<ToySettingsScreen> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late Toy _currentToy;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _currentToy = widget.toy;
    _nameController = TextEditingController(text: _currentToy.name);
    _refreshToyStatus();
    _statusTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshToyStatus(),
    );
  }

  Future<void> _refreshToyStatus() async {
    try {
      final updated =
          await ref.read(toyProvider.notifier).getToyById(_currentToy.id);
      if (mounted) {
        setState(() => _currentToy = updated);
      }
    } on Exception catch (_) {
      // Ignore refresh errors silently
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateToySettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(toyProvider.notifier).updateToy(
            id: _currentToy.id,
            name: _nameController.text,
          );

      if (mounted) {
        context.showSuccessSnackBar('toy_settings.update_success'.tr());
      }
    } on Exception {
      if (mounted) {
        context.showErrorSnackBar('toy_settings.update_error'.tr());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteToy() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(toyProvider.notifier).deleteToy(_currentToy.id);

      if (mounted) {
        context
          ..showSuccessSnackBar('toy_settings.remove_success'.tr())
          ..pop();
      }
    } on Exception {
      if (mounted) {
        context.showErrorSnackBar('toy_settings.remove_error'.tr());
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'toy_settings.remove_title'.tr(),
      content: 'toy_settings.remove_confirm'.tr(args: [_currentToy.name]),
      destructive: true,
    );
    if (confirmed) {
      await _deleteToy();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(title: Text('toy_settings.title'.tr())),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                context.spacing.alertPadding,
                context.spacing.alertPadding,
                context.spacing.alertPadding,
                context.spacing.alertPadding + MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toy Info Card
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(context.spacing.alertPadding),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor:
                                  context.colors.primary.withValues(alpha: 0.2),
                              child: Icon(
                                Icons.smart_toy,
                                size: 48,
                                color: context.colors.primary,
                              ),
                            ),
                            SizedBox(height: context.spacing.sectionTitleBottomMargin),
                            Text(
                              _currentToy.model ?? 'toy_settings.unknown_model'.tr(),
                              style: theme.textTheme.titleLarge,
                            ),
                            SizedBox(height: context.spacing.titleBottomMarginSm),
                            Text(
                              'ID: ${_currentToy.iotDeviceId}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.disabledColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: context.spacing.panelPadding),

                    // Name Setting
                    Text(
                      'toy_settings.toy_name'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing.titleBottomMarginSm),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'toy_settings.toy_name_hint'.tr(),
                        prefixIcon: const Icon(Icons.label),
                        border: OutlineInputBorder(
                          borderRadius: context.radius.tile,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'toy_settings.toy_name_required'.tr();
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: context.spacing.panelPadding),

                    // Device Status
                    Text(
                      'toy_settings.device_status'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing.titleBottomMarginSm),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(context.spacing.alertPadding),
                        child: Column(
                          children: [
                            _buildStatusRow(
                              'toy_settings.status'.tr(),
                              _currentToy.status.toString().split('.').last,
                              theme,
                            ),
                            const Divider(),
                            if (_currentToy.iotDeviceStatus != null)
                              _buildStatusRow(
                                'toy_settings.device_connection'.tr(),
                                _currentToy.iotDeviceStatus!,
                                theme,
                                statusColor: _currentToy.iotDeviceStatus == 'online'
                                    ? context.colors.success
                                    : context.colors.error,
                              ),
                            if (_currentToy.iotDeviceStatus != null)
                              const Divider(),
                            if (_currentToy.batteryLevel != null)
                              _buildStatusRow(
                                'toy_settings.battery'.tr(),
                                _currentToy.batteryLevel!,
                                theme,
                              ),
                            if (_currentToy.batteryLevel != null)
                              const Divider(),
                            _buildStatusRow(
                              'toy_settings.model'.tr(),
                              _currentToy.model ?? 'toy_settings.unknown'.tr(),
                              theme,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: context.spacing.panelPadding),

                    // Audio Controls (Volume & Mute)
                    Text(
                      'toy_settings.audio_controls'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing.titleBottomMarginSm),
                    const ESP32AudioControls(),

                    SizedBox(height: context.spacing.panelPadding),

                    // Walkie Talkie
                    Text(
                      'walkie_talkie.title'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing.titleBottomMarginSm),
                    ElevatedButton.icon(
                      onPressed: _currentToy.iotDeviceId != null
                          ? () => context.push(
                                AppRoutes.walkieTalkie.path,
                                extra: _currentToy,
                              )
                          : null,
                      icon: const Icon(Icons.record_voice_over),
                      label: Text('walkie_talkie.open_button'.tr()),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: context.colors.primary,
                      ),
                    ),
                    if (_currentToy.iotDeviceId == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'walkie_talkie.no_iot_device'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.textOnFilled.withValues(alpha: 0.6),
                          ),
                        ),
                      ),

                    SizedBox(height: context.spacing.paragraphBottomMargin),

                    // Save Button
                    ElevatedButton(
                      onPressed: _updateToySettings,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: context.colors.primary,
                      ),
                      child: Text('toy_settings.save_changes'.tr()),
                    ),

                    SizedBox(height: context.spacing.sectionTitleBottomMargin),

                    // Remove Toy Button
                    OutlinedButton.icon(
                      onPressed: _showDeleteConfirmation,
                      icon: Icon(Icons.delete, color: context.colors.error),
                      label: Text(
                        'toy_settings.remove_title'.tr(),
                        style: TextStyle(color: context.colors.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.colors.error),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusRow(
    String label,
    String value,
    ThemeData theme, {
    Color? statusColor,
  }) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (statusColor != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      );
}
