import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/toy_status_helper.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/toy.dart';
import '../providers/personality_provider.dart';
import '../providers/toy_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';
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
    // Local toys don't exist on backend — skip API refresh
    if (_currentToy.id.startsWith('local_')) {
      return;
    }
    try {
      final updated = await ref
          .read(toyProvider.notifier)
          .getToyById(_currentToy.id);
      if (mounted) {
        setState(() {
          _currentToy = updated;
        });
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

    setState(() {
      _isLoading = true;
    });

    try {
      final updated = await ref
          .read(toyProvider.notifier)
          .updateToy(id: _currentToy.id, name: _nameController.text.trim());

      if (mounted) {
        setState(() {
          _currentToy = updated;
        });
        context.showSuccessSnackBar('toy_settings.update_success'.tr());
      }
    } on Exception {
      if (mounted) {
        context.showErrorSnackBar('toy_settings.update_error'.tr());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteToy() async {
    setState(() {
      _isLoading = true;
    });

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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _unassignToy() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(toyProvider.notifier).unassignToy(_currentToy.id);

      if (mounted) {
        context
          ..showSuccessSnackBar('toy_settings.unassign_success'.tr())
          ..pop();
      }
    } on Exception {
      if (mounted) {
        context.showErrorSnackBar('toy_settings.unassign_error'.tr());
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showUnassignConfirmation() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'toy_settings.unassign_title'.tr(),
      content: 'toy_settings.unassign_confirm'.tr(args: [_currentToy.name]),
    );
    if (confirmed && mounted) {
      await _unassignToy();
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'toy_settings.remove_title'.tr(),
      content: 'toy_settings.remove_confirm'.tr(args: [_currentToy.name]),
      destructive: true,
    );
    if (confirmed && mounted) {
      await _deleteToy();
    }
  }

  Future<void> _showPersonalityPicker() async {
    final personalities = ref.read(personalitiesProvider).value;
    if (personalities == null || personalities.isEmpty) {
      return;
    }

    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        final theme = ctx.theme;
        final colorScheme = theme.colorScheme;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(context.spacing.alertPadding),
                child: Text(
                  'toy_settings.personality_change'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...personalities.map(
                (p) => ListTile(
                  leading: Icon(
                    _iconForPersonality(p.id),
                    color: p.id == _currentToy.personalityProfile
                        ? context.colors.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    p.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: p.id == _currentToy.personalityProfile
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: p.id == _currentToy.personalityProfile
                          ? context.colors.primary
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    p.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: p.id == _currentToy.personalityProfile
                      ? Icon(Icons.check_circle, color: context.colors.primary)
                      : null,
                  onTap: () => Navigator.pop(ctx, p.id),
                ),
              ),
              SizedBox(height: context.spacing.panelPadding),
            ],
          ),
        );
      },
    );

    if (selected == null || !mounted) {
      return;
    }
    if (selected == _currentToy.personalityProfile) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updated = await ref
          .read(toyProvider.notifier)
          .updateToy(id: _currentToy.id, personalityProfile: selected);

      if (mounted) {
        setState(() {
          _currentToy = updated;
        });
        context.showSuccessSnackBar('toy_settings.personality_updated'.tr());
      }
    } on Exception {
      if (mounted) {
        context.showErrorSnackBar('toy_settings.personality_error'.tr());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  IconData _iconForPersonality(String id) => switch (id) {
    'mexican' => Icons.celebration_rounded,
    'peruvian' => Icons.terrain_rounded,
    'kpop' => Icons.music_note_rounded,
    'roblox' => Icons.sports_esports_rounded,
    _ => Icons.smart_toy_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('toy_settings.title'.tr())),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                context.spacing.alertPadding,
                context.spacing.alertPadding,
                context.spacing.alertPadding,
                context.spacing.alertPadding +
                    MediaQuery.of(context).padding.bottom +
                    24,
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
                              backgroundColor: context.colors.primary
                                  .withValues(alpha: 0.2),
                              child: Icon(
                                Icons.smart_toy,
                                size: 48,
                                color: context.colors.primary,
                              ),
                            ),
                            SizedBox(
                              height: context.spacing.sectionTitleBottomMargin,
                            ),
                            Text(
                              _currentToy.model ??
                                  'toy_settings.unknown_model'.tr(),
                              style: theme.textTheme.titleLarge,
                            ),
                            if (_currentToy.iotDeviceId != null) ...[
                              SizedBox(
                                height: context.spacing.titleBottomMarginSm,
                              ),
                              Text(
                                'ID: ${_currentToy.iotDeviceId}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.disabledColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: context.spacing.panelPadding),

                    // Name Setting
                    CustomInput(
                      label: 'toy_settings.toy_name'.tr(),
                      controller: _nameController,
                      hint: 'toy_settings.toy_name_hint'.tr(),
                      prefixIcon: const Icon(Icons.label),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'toy_settings.toy_name_required'.tr();
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: context.spacing.panelPadding),

                    // Personality Section
                    Text(
                      'toy_settings.personality'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.spacing.titleBottomMarginSm),
                    _buildPersonalityCard(theme, colorScheme),

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
                              _currentToy.status.label(),
                              theme,
                              statusColor: _currentToy.status.color(context),
                            ),
                            const Divider(),
                            if (_currentToy.iotDeviceStatus != null) ...[
                              _buildStatusRow(
                                'toy_settings.device_connection'.tr(),
                                _currentToy.iotDeviceStatus!,
                                theme,
                                statusColor:
                                    _currentToy.iotDeviceStatus == 'online'
                                    ? context.colors.success
                                    : context.colors.error,
                              ),
                              const Divider(),
                            ],
                            if (_currentToy.batteryLevel != null) ...[
                              _buildStatusRow(
                                'toy_settings.battery'.tr(),
                                _currentToy.batteryLevel!,
                                theme,
                              ),
                              const Divider(),
                            ],
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
                    CustomButton(
                      text: 'walkie_talkie.open_button'.tr(),
                      icon: Icons.record_voice_over,
                      isFullWidth: true,
                      height: 48,
                      onPressed: _currentToy.iotDeviceId != null
                          ? () => context.push(
                              AppRoutes.walkieTalkie.path,
                              extra: _currentToy,
                            )
                          : null,
                    ),
                    if (_currentToy.iotDeviceId == null)
                      Padding(
                        padding: EdgeInsets.only(
                          top: context.spacing.labelBottomMargin,
                        ),
                        child: Text(
                          'walkie_talkie.no_iot_device'.tr(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: context.colors.textDisabled,
                          ),
                        ),
                      ),

                    SizedBox(height: context.spacing.paragraphBottomMargin),

                    CustomButton(
                      text: 'toy_settings.save_changes'.tr(),
                      isFullWidth: true,
                      height: 48,
                      onPressed: _updateToySettings,
                    ),

                    SizedBox(height: context.spacing.sectionTitleBottomMargin),

                    if (!_currentToy.id.startsWith('local_'))
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: context.spacing.sectionTitleBottomMargin,
                        ),
                        child: CustomButton(
                          text: 'toy_settings.unassign_title'.tr(),
                          icon: Icons.link_off,
                          variant: ButtonVariant.outline,
                          isFullWidth: true,
                          height: 48,
                          onPressed: _showUnassignConfirmation,
                        ),
                      ),

                    CustomButton(
                      text: 'toy_settings.remove_title'.tr(),
                      icon: Icons.delete,
                      variant: ButtonVariant.dangerOutline,
                      isFullWidth: true,
                      height: 48,
                      onPressed: _showDeleteConfirmation,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPersonalityCard(ThemeData theme, ColorScheme colorScheme) {
    final profileId = _currentToy.personalityProfile;
    final isLocal = _currentToy.id.startsWith('local_');

    return Card(
      child: InkWell(
        onTap: isLocal ? null : _showPersonalityPicker,
        borderRadius: context.radius.tile,
        child: Padding(
          padding: EdgeInsets.all(context.spacing.alertPadding),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.12),
                  borderRadius: context.radius.panel,
                ),
                child: Icon(
                  profileId != null
                      ? _iconForPersonality(profileId)
                      : Icons.smart_toy_rounded,
                  color: context.colors.primary,
                ),
              ),
              SizedBox(width: context.spacing.panelPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'toy_settings.personality_current'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: context.spacing.labelBottomMargin),
                    Text(
                      _personalityDisplayName(profileId),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLocal)
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _personalityDisplayName(String? profileId) {
    if (profileId == null || profileId.isEmpty) {
      return 'toy_settings.personality_none'.tr();
    }

    // Try to get the display name from the loaded personalities
    final personalities = ref.read(personalitiesProvider).value;
    if (personalities != null) {
      for (final p in personalities) {
        if (p.id == profileId) {
          return p.name;
        }
      }
    }

    // Fallback: capitalize the profile ID
    return profileId[0].toUpperCase() + profileId.substring(1);
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
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor),
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
            SizedBox(width: context.spacing.gapSm),
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
