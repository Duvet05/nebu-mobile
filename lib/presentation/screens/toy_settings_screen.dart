import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/validation_rules.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/toy_status_helper.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/toy.dart';
import '../providers/api_provider.dart';
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
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _savingSettings = false;
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
    } on Exception catch (e) {
      ref.read(loggerProvider).d('Toy status refresh failed: $e');
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  bool get _anyLoading => _isSaving || _isDeleting || _savingSettings;

  Future<void> _updateToySettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
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
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteToy() async {
    setState(() {
      _isDeleting = true;
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
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _unassignToy() async {
    setState(() {
      _isDeleting = true;
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
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
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
        final sheetTheme = ctx.theme;
        final sheetColors = sheetTheme.colorScheme;

        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(ctx.spacing.alertPadding),
                child: Text(
                  'toy_settings.personality_change'.tr(),
                  style: sheetTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...personalities.map(
                (p) => ListTile(
                  leading: Icon(
                    _iconForPersonality(p.id),
                    color: p.id == _currentToy.personalityProfile
                        ? ctx.colors.primary
                        : sheetColors.onSurfaceVariant,
                  ),
                  title: Text(
                    p.name,
                    style: sheetTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: p.id == _currentToy.personalityProfile
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: p.id == _currentToy.personalityProfile
                          ? ctx.colors.primary
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    p.description,
                    style: sheetTheme.textTheme.bodySmall?.copyWith(
                      color: sheetColors.onSurfaceVariant,
                    ),
                  ),
                  trailing: p.id == _currentToy.personalityProfile
                      ? Icon(Icons.check_circle, color: ctx.colors.primary)
                      : null,
                  onTap: () => Navigator.pop(ctx, p.id),
                ),
              ),
              SizedBox(height: ctx.spacing.panelPadding),
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
      _isSaving = true;
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
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _toggleSettingsFlag(String flag, bool value) async {
    setState(() {
      _savingSettings = true;
    });

    try {
      final currentSettings =
          Map<String, dynamic>.from(_currentToy.settings ?? {});
      currentSettings[flag] = value;

      final updated = await ref
          .read(toyProvider.notifier)
          .updateToy(id: _currentToy.id, settings: currentSettings);

      if (mounted) {
        setState(() {
          _currentToy = updated;
        });
        context.showSuccessSnackBar('toy_settings.settings_saved'.tr());
      }
    } on Exception {
      if (mounted) {
        context.showErrorSnackBar('toy_settings.settings_error'.tr());
      }
    } finally {
      if (mounted) {
        setState(() {
          _savingSettings = false;
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
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          context.spacing.alertPadding,
          context.spacing.alertPadding,
          context.spacing.alertPadding,
          context.spacing.alertPadding +
              MediaQuery.of(context).padding.bottom +
              context.spacing.panelPadding,
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
                          'toy_settings.device_id'.tr(args: [_currentToy.iotDeviceId!]),
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
                validator: (value) =>
                    ValidationRules.validateToyName(value)?.tr(),
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

              // Advanced Settings (feature flags)
              if (!_currentToy.id.startsWith('local_')) ...[
                SizedBox(height: context.spacing.panelPadding),
                Text(
                  'toy_settings.advanced_settings'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: context.spacing.titleBottomMarginSm),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(
                          'toy_settings.variety_engine'.tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'toy_settings.variety_engine_desc'.tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        secondary: Icon(
                          Icons.auto_awesome_rounded,
                          color: context.colors.primary,
                        ),
                        value: _currentToy
                                    .settings?['enableVarietyEngine'] ==
                                true,
                        onChanged: _anyLoading
                            ? null
                            : (v) => _toggleSettingsFlag(
                                'enableVarietyEngine', v),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: Text(
                          'toy_settings.walkie_talkie_mode'.tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'toy_settings.walkie_talkie_mode_desc'.tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        secondary: Icon(
                          Icons.family_restroom_rounded,
                          color: context.colors.primary,
                        ),
                        value: _currentToy
                                    .settings?['enableWalkieTalkie'] ==
                                true,
                        onChanged: _anyLoading
                            ? null
                            : (v) => _toggleSettingsFlag(
                                'enableWalkieTalkie', v),
                      ),
                    ],
                  ),
                ),
              ],

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
                onPressed: _currentToy.iotDeviceId != null && !_anyLoading
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
                isLoading: _isSaving,
                height: 48,
                onPressed: _anyLoading ? null : _updateToySettings,
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
                    isLoading: _isDeleting,
                    height: 48,
                    onPressed: _anyLoading ? null : _showUnassignConfirmation,
                  ),
                ),

              CustomButton(
                text: 'toy_settings.remove_title'.tr(),
                icon: Icons.delete,
                variant: ButtonVariant.dangerOutline,
                isFullWidth: true,
                isLoading: _isDeleting,
                height: 48,
                onPressed: _anyLoading ? null : _showDeleteConfirmation,
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
    final displayName = _personalityDisplayName(profileId);

    return Semantics(
      button: !isLocal,
      label: isLocal
          ? 'toy_settings.personality_current'.tr()
          : '${'toy_settings.personality_change'.tr()}, $displayName',
      child: Card(
        child: InkWell(
          onTap: isLocal || _anyLoading ? null : _showPersonalityPicker,
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
                        displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLocal)
                  ExcludeSemantics(
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
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
      Expanded(
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor),
        ),
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (statusColor != null) ...[
            Semantics(
              label: value,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
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
