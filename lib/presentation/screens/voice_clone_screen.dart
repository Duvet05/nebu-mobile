import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/toy.dart';
import '../providers/toy_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

/// Graba una muestra de voz (5-15s) y la envía al backend para clonarla
/// con Inworld como voz personalizada del juguete.
class VoiceCloneScreen extends ConsumerStatefulWidget {
  const VoiceCloneScreen({required this.toy, super.key});

  final Toy toy;

  static const int minSeconds = 5;
  static const int maxSeconds = 15;

  @override
  ConsumerState<VoiceCloneScreen> createState() => _VoiceCloneScreenState();
}

class _VoiceCloneScreenState extends ConsumerState<VoiceCloneScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final TextEditingController _nameController = TextEditingController();

  bool _isRecording = false;
  bool _isUploading = false;
  bool _consentAccepted = false;
  int _elapsedSeconds = 0;
  int _recordedSeconds = 0;
  String? _recordingPath;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) {
      if (mounted) {
        context.showErrorSnackBar('voice_clone.mic_permission_denied'.tr());
      }
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final path =
        '${tempDir.path}/voice_clone_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.wav, numChannels: 1),
      path: path,
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _isRecording = true;
      _elapsedSeconds = 0;
      _recordedSeconds = 0;
      _recordingPath = null;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() => _elapsedSeconds++);
      if (_elapsedSeconds >= VoiceCloneScreen.maxSeconds) {
        _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _timer = null;
    final path = await _recorder.stop();

    if (!mounted) {
      return;
    }

    if (_elapsedSeconds < VoiceCloneScreen.minSeconds) {
      setState(() {
        _isRecording = false;
        _recordingPath = null;
      });
      context.showErrorSnackBar('voice_clone.too_short'.tr());
      return;
    }

    setState(() {
      _isRecording = false;
      _recordedSeconds = _elapsedSeconds;
      _recordingPath = path;
    });
  }

  Future<void> _discardRecording() async {
    final path = _recordingPath;
    setState(() {
      _recordingPath = null;
      _recordedSeconds = 0;
      _elapsedSeconds = 0;
    });
    if (path != null) {
      try {
        await File(path).delete();
      } on FileSystemException {
        // Archivo temporal: si no se puede borrar, el SO lo limpiará
      }
    }
  }

  String? get _langCode => switch (context.locale.languageCode) {
    'es' => 'ES_ES',
    'en' => 'EN_US',
    'pt' => 'PT_BR',
    _ => null,
  };

  Future<void> _submit() async {
    final path = _recordingPath;
    if (path == null || _isUploading) {
      return;
    }

    setState(() => _isUploading = true);

    try {
      final updatedToy = await ref
          .read(toyProvider.notifier)
          .cloneToyVoice(
            id: widget.toy.id,
            audioFilePath: path,
            displayName: _nameController.text.trim().isEmpty
                ? null
                : _nameController.text.trim(),
            langCode: _langCode,
          );

      if (mounted) {
        context
          ..showSuccessSnackBar(
            'voice_clone.success'.tr(args: [widget.toy.name]),
          )
          ..pop(updatedToy);
      }
    } on Exception {
      if (mounted) {
        context.showErrorSnackBar('voice_clone.error'.tr());
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final hasRecording = _recordingPath != null;
    final canSubmit = hasRecording && _consentAccepted && !_isUploading;

    return Scaffold(
      appBar: AppBar(title: Text('voice_clone.title'.tr())),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: context.constrainedPageEdgeInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: context.spacing.panelPadding),
              Text(
                'voice_clone.subtitle'.tr(args: [widget.toy.name]),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: context.spacing.gapXl),
              _buildInstructionsCard(theme, colorScheme),
              SizedBox(height: context.spacing.gapXl),
              _buildSampleTextCard(theme, colorScheme),
              SizedBox(height: context.spacing.gapXl),
              _buildRecorderCard(theme, colorScheme),
              if (hasRecording) ...[
                SizedBox(height: context.spacing.gapXl),
                CustomInput(
                  label: 'voice_clone.name_label'.tr(),
                  hint: 'voice_clone.name_hint'.tr(),
                  controller: _nameController,
                  maxLength: 60,
                  enabled: !_isUploading,
                ),
                SizedBox(height: context.spacing.gapLg),
                CheckboxListTile(
                  value: _consentAccepted,
                  onChanged: _isUploading
                      ? null
                      : (value) =>
                            setState(() => _consentAccepted = value ?? false),
                  title: Text(
                    'voice_clone.consent_label'.tr(),
                    style: theme.textTheme.bodySmall,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                SizedBox(height: context.spacing.gapLg),
                CustomButton(
                  text: 'voice_clone.submit'.tr(),
                  onPressed: canSubmit ? _submit : null,
                  isLoading: _isUploading,
                  isFullWidth: true,
                  icon: Icons.auto_awesome,
                ),
              ],
              SizedBox(height: context.spacing.panelPadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsCard(ThemeData theme, ColorScheme colorScheme) =>
      Card(
        child: Padding(
          padding: EdgeInsets.all(context.spacing.alertPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'voice_clone.instructions_title'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: context.spacing.gapLg),
              for (final key in const [
                'voice_clone.instruction_1',
                'voice_clone.instruction_2',
                'voice_clone.instruction_3',
              ]) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: context.colors.primary,
                    ),
                    SizedBox(width: context.spacing.gapLg),
                    Expanded(
                      child: Text(key.tr(), style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
                SizedBox(height: context.spacing.gapXs),
              ],
            ],
          ),
        ),
      );

  Widget _buildSampleTextCard(ThemeData theme, ColorScheme colorScheme) => Card(
    color: context.colors.primary.withValues(alpha: 0.06),
    child: Padding(
      padding: EdgeInsets.all(context.spacing.alertPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'voice_clone.sample_title'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.spacing.labelBottomMargin),
          Text(
            'voice_clone.sample_text'.tr(),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildRecorderCard(ThemeData theme, ColorScheme colorScheme) {
    final hasRecording = _recordingPath != null;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.spacing.alertPadding),
        child: Column(
          children: [
            if (_isRecording) ...[
              Text(
                'voice_clone.recording_hint'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: context.colors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: context.spacing.gapLg),
              Text(
                '$_elapsedSeconds / ${VoiceCloneScreen.maxSeconds}s',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: context.spacing.gapLg),
              LinearProgressIndicator(
                value: _elapsedSeconds / VoiceCloneScreen.maxSeconds,
                borderRadius: BorderRadius.circular(4),
              ),
              SizedBox(height: context.spacing.gapXl),
              CustomButton(
                text: 'voice_clone.stop_button'.tr(),
                onPressed: _stopRecording,
                isFullWidth: true,
                icon: Icons.stop_rounded,
              ),
            ] else if (hasRecording) ...[
              Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: context.colors.success,
              ),
              SizedBox(height: context.spacing.gapLg),
              Text(
                'voice_clone.recorded_hint'.tr(args: ['$_recordedSeconds']),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: context.spacing.gapXl),
              CustomButton(
                text: 'voice_clone.re_record'.tr(),
                onPressed: _isUploading ? null : _discardRecording,
                variant: ButtonVariant.secondary,
                isFullWidth: true,
                icon: Icons.refresh_rounded,
              ),
            ] else ...[
              Icon(Icons.mic_rounded, size: 48, color: context.colors.primary),
              SizedBox(height: context.spacing.gapLg),
              Text(
                'voice_clone.record_hint'.tr(
                  args: [
                    '${VoiceCloneScreen.minSeconds}',
                    '${VoiceCloneScreen.maxSeconds}',
                  ],
                ),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: context.spacing.gapXl),
              CustomButton(
                text: 'voice_clone.record_button'.tr(),
                onPressed: _startRecording,
                isFullWidth: true,
                icon: Icons.mic_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
