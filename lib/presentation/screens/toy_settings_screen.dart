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
import '../widgets/nebu_voice_options.dart';
import 'setup/setup_route_args.dart';

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

  String? get _currentVoiceId {
    final value = _currentToy.settings?['voicePreference'];
    return value is String && value.isNotEmpty ? value : null;
  }

  /// Voz clonada del juguete (settings.clonedVoice), si existe
  Map<String, dynamic>? get _clonedVoice {
    final value = _currentToy.settings?['clonedVoice'];
    return value is Map<String, dynamic> ? value : null;
  }

  String? get _clonedVoiceId {
    final value = _clonedVoice?['id'];
    return value is String && value.isNotEmpty ? value : null;
  }

  String get _clonedVoiceName {
    final value = _clonedVoice?['name'];
    return value is String && value.isNotEmpty
        ? value
        : 'toy_settings.voice_cloned'.tr();
  }

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

  void _changeWifi() {
    unawaited(
      context.push(
        AppRoutes.connectionSetup.path,
        extra: ConnectionSetupRouteArgs(
          mode: SetupFlowMode.changeWifi,
          returnRoute: AppRoutes.toySettings.path,
          returnExtra: _currentToy,
        ),
      ),
    );
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

  Future<void> _showVoicePicker() async {
    final currentVoiceId = _currentVoiceId;
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
                  'toy_settings.voice_change'.tr(),
                  style: sheetTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...nebuVoiceOptions.map(
                (voice) => ListTile(
                  leading: Icon(
                    voice.icon,
                    color: voice.id == currentVoiceId
                        ? ctx.colors.primary
                        : sheetColors.onSurfaceVariant,
                  ),
                  title: Text(
                    voice.labelKey.tr(),
                    style: sheetTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: voice.id == currentVoiceId
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: voice.id == currentVoiceId
                          ? ctx.colors.primary
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    voice.descriptionKey.tr(),
                    style: sheetTheme.textTheme.bodySmall?.copyWith(
                      color: sheetColors.onSurfaceVariant,
                    ),
                  ),
                  trailing: voice.id == currentVoiceId
                      ? Icon(Icons.check_circle, color: ctx.colors.primary)
                      : null,
                  onTap: () => Navigator.pop(ctx, voice.id),
                ),
              ),
              if (_clonedVoiceId != null)
                ListTile(
                  leading: Icon(
                    Icons.graphic_eq_rounded,
                    color: _clonedVoiceId == currentVoiceId
                        ? ctx.colors.primary
                        : sheetColors.onSurfaceVariant,
                  ),
                  title: Text(
                    _clonedVoiceName,
                    style: sheetTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: _clonedVoiceId == currentVoiceId
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: _clonedVoiceId == currentVoiceId
                          ? ctx.colors.primary
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    'toy_settings.voice_cloned_desc'.tr(),
                    style: sheetTheme.textTheme.bodySmall?.copyWith(
                      color: sheetColors.onSurfaceVariant,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_clonedVoiceId == currentVoiceId)
                        Icon(Icons.check_circle, color: ctx.colors.primary),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: ctx.colors.error,
                        ),
                        tooltip: 'toy_settings.voice_clone_remove_title'.tr(),
                        onPressed: () =>
                            Navigator.pop(ctx, _removeCloneSentinel),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.pop(ctx, _clonedVoiceId),
                ),
              ListTile(
                leading: Icon(Icons.mic_rounded, color: ctx.colors.primary),
                title: Text(
                  'toy_settings.voice_clone_new'.tr(),
                  style: sheetTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ctx.colors.primary,
                  ),
                ),
                subtitle: Text(
                  'toy_settings.voice_clone_new_desc'.tr(),
                  style: sheetTheme.textTheme.bodySmall?.copyWith(
                    color: sheetColors.onSurfaceVariant,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, _cloneNewSentinel),
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
    if (selected == _cloneNewSentinel) {
      await _openVoiceCloneScreen();
      return;
    }
    if (selected == _removeCloneSentinel) {
      await _confirmRemoveClonedVoice();
      return;
    }
    if (selected == currentVoiceId) {
      return;
    }

    await _updateVoicePreference(selected);
  }

  static const String _cloneNewSentinel = '__clone_new_voice__';
  static const String _removeCloneSentinel = '__remove_cloned_voice__';

  Future<void> _openVoiceCloneScreen() async {
    final updatedToy = await context.push<Toy>(
      AppRoutes.voiceClone.path,
      extra: _currentToy,
    );
    if (updatedToy != null && mounted) {
      setState(() {
        _currentToy = updatedToy;
      });
    }
  }

  Future<void> _confirmRemoveClonedVoice() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'toy_settings.voice_clone_remove_title'.tr(),
      content: 'toy_settings.voice_clone_remove_confirm'.tr(
        args: [_clonedVoiceName],
      ),
      destructive: true,
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _savingSettings = true;
    });

    try {
      final updated = await ref
          .read(toyProvider.notifier)
          .removeClonedVoice(_currentToy.id);

      if (mounted) {
        setState(() {
          _currentToy = updated;
        });
        context.showSuccessSnackBar('toy_settings.voice_clone_removed'.tr());
      }
    } on Exception {
      if (mounted) {
        context.showErrorSnackBar('toy_settings.voice_clone_remove_error'.tr());
      }
    } finally {
      if (mounted) {
        setState(() {
          _savingSettings = false;
        });
      }
    }
  }

  Future<void> _updateVoicePreference(String voiceId) async {
    setState(() {
      _savingSettings = true;
    });

    try {
      final currentSettings = Map<String, dynamic>.from(
        _currentToy.settings ?? {},
      );
      currentSettings['voicePreference'] = voiceId;

      final updated = await ref
          .read(toyProvider.notifier)
          .updateToy(id: _currentToy.id, settings: currentSettings);

      if (mounted) {
        setState(() {
          _currentToy = updated;
        });
        context.showSuccessSnackBar('toy_settings.voice_updated'.tr());
      }
    } on Exception {
      if (mounted) {
        context.showErrorSnackBar('toy_settings.voice_error'.tr());
      }
    } finally {
      if (mounted) {
        setState(() {
          _savingSettings = false;
        });
      }
    }
  }

  Future<void> _toggleSettingsFlag(String flag, bool value) async {
    setState(() {
      _savingSettings = true;
    });

    try {
      final currentSettings = Map<String, dynamic>.from(
        _currentToy.settings ?? {},
      );
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
                        backgroundColor: context.colors.primary.withValues(
                          alpha: 0.2,
                        ),
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
                        _currentToy.model ?? 'toy_settings.unknown_model'.tr(),
                        style: theme.textTheme.titleLarge,
                      ),
                      if (_currentToy.iotDeviceId != null) ...[
                        SizedBox(height: context.spacing.titleBottomMarginSm),
                        Text(
                          'toy_settings.device_id'.tr(
                            args: [_currentToy.iotDeviceId!],
                          ),
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

              // Voice Section
              Text(
                'toy_settings.voice'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: context.spacing.titleBottomMarginSm),
              _buildVoiceCard(theme, colorScheme),

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
                          statusColor: _currentToy.iotDeviceStatus == 'online'
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

              CustomButton(
                text: 'toy_settings.change_wifi'.tr(),
                icon: Icons.wifi_rounded,
                isFullWidth: true,
                height: 72,
                onPressed: _anyLoading ? null : _changeWifi,
              ),

              SizedBox(height: context.spacing.panelPadding),

              _buildInDevelopmentSection(theme, colorScheme),

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
                        value:
                            _currentToy.settings?['enableVarietyEngine'] ==
                            true,
                        onChanged: _anyLoading
                            ? null
                            : (v) =>
                                  _toggleSettingsFlag('enableVarietyEngine', v),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: context.spacing.panelPadding),

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

  Widget _buildInDevelopmentSection(ThemeData theme, ColorScheme colorScheme) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'toy_settings.development_title'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.spacing.titleBottomMarginSm),
          Semantics(
            enabled: false,
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(context.spacing.alertPadding),
                    color: context.colors.warning.withValues(alpha: 0.12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.construction_rounded,
                          color: context.colors.warning,
                        ),
                        SizedBox(width: context.spacing.gapMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'toy_settings.development_badge'.tr(),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: context.colors.warning,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: context.spacing.gapXs),
                              Text(
                                'toy_settings.development_desc'.tr(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildDisabledFeatureTile(
                    theme: theme,
                    colorScheme: colorScheme,
                    icon: Icons.volume_up_rounded,
                    title: 'toy_settings.audio_controls'.tr(),
                    subtitle: 'toy_settings.audio_controls_desc'.tr(),
                  ),
                  const Divider(height: 1),
                  _buildDisabledFeatureTile(
                    theme: theme,
                    colorScheme: colorScheme,
                    icon: Icons.family_restroom_rounded,
                    title: 'toy_settings.walkie_talkie_mode'.tr(),
                    subtitle: 'toy_settings.walkie_talkie_mode_desc'.tr(),
                  ),
                  const Divider(height: 1),
                  _buildDisabledFeatureTile(
                    theme: theme,
                    colorScheme: colorScheme,
                    icon: Icons.record_voice_over_rounded,
                    title: 'walkie_talkie.title'.tr(),
                    subtitle: 'toy_settings.walkie_talkie_desc'.tr(),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _buildDisabledFeatureTile({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required IconData icon,
    required String title,
    required String subtitle,
  }) => ListTile(
    enabled: false,
    leading: Icon(icon),
    title: Text(
      title,
      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
    subtitle: Text(
      subtitle,
      style: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    ),
    trailing: const Icon(Icons.lock_outline_rounded),
  );

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

  Widget _buildVoiceCard(ThemeData theme, ColorScheme colorScheme) {
    final voiceId = _currentVoiceId;
    final isLocal = _currentToy.id.startsWith('local_');
    final displayName = _voiceDisplayName(voiceId);
    final option = findNebuVoiceOption(voiceId);

    return Semantics(
      button: !isLocal,
      label: isLocal
          ? 'toy_settings.voice_current'.tr()
          : '${'toy_settings.voice_change'.tr()}, $displayName',
      child: Card(
        child: InkWell(
          onTap: isLocal || _anyLoading ? null : _showVoicePicker,
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
                    option?.icon ?? Icons.record_voice_over_rounded,
                    color: context.colors.primary,
                  ),
                ),
                SizedBox(width: context.spacing.panelPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'toy_settings.voice_current'.tr(),
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

  String _voiceDisplayName(String? voiceId) {
    if (voiceId == null || voiceId.isEmpty) {
      return 'toy_settings.voice_none'.tr();
    }

    if (voiceId == _clonedVoiceId) {
      return _clonedVoiceName;
    }

    final option = findNebuVoiceOption(voiceId);
    return option?.labelKey.tr() ?? voiceId;
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
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.disabledColor,
          ),
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
