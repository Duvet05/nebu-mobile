import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../providers/esp32_provider.dart';

/// Widget de controles de audio para el ESP32
/// Proporciona un slider de volumen y botón de mute
class ESP32AudioControls extends ConsumerStatefulWidget {
  const ESP32AudioControls({super.key});

  @override
  ConsumerState<ESP32AudioControls> createState() => _ESP32AudioControlsState();
}

class _ESP32AudioControlsState extends ConsumerState<ESP32AudioControls> {
  bool _isUpdatingVolume = false;
  bool _isUpdatingMute = false;
  double _localVolume = 50; // Local UI state for smooth slider

  @override
  Widget build(BuildContext context) {
    final int volume = ref.watch(esp32VolumeProvider) ?? 50;
    final bool isMuted = ref.watch(esp32MuteProvider) ?? false;
    final setVolume = ref.read(esp32SetVolumeProvider);
    final setMute = ref.read(esp32SetMuteProvider);

    // Sync local volume with actual volume when not dragging
    if (!_isUpdatingVolume) {
      _localVolume = volume.toDouble();
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(context.spacing.alertPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Volume Slider
            Row(
              children: [
                Icon(
                  Icons.volume_down,
                  size: 20,
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
                Expanded(
                  child: Slider(
                    value: _localVolume,
                    max: 100,
                    divisions: 20,
                    label: '${_localVolume.toInt()}%',
                    onChanged: _isUpdatingVolume
                        ? null
                        : (value) {
                            setState(() {
                              _localVolume = value;
                            });
                          },
                    onChangeEnd: (value) async {
                      setState(() => _isUpdatingVolume = true);
                      try {
                        final success = await setVolume(value.toInt());
                        if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('audio_controls.volume_error'.tr()),
                              backgroundColor: context.colors.error,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isUpdatingVolume = false);
                        }
                      }
                    },
                  ),
                ),
                Icon(
                  Icons.volume_up,
                  size: 20,
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: context.spacing.gapMd),
                SizedBox(
                  width: 45,
                  child: Text(
                    '${_localVolume.toInt()}%',
                    style: context.theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),

            SizedBox(height: context.spacing.titleBottomMarginSm),

            // Mute Button
            Row(
              children: [
                Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  size: 20,
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: context.spacing.gapMd),
                Expanded(
                  child: Text(
                    isMuted
                        ? 'audio_controls.muted'.tr()
                        : 'audio_controls.unmuted'.tr(),
                    style: context.theme.textTheme.bodyMedium,
                  ),
                ),
                Switch(
                  value: isMuted,
                  onChanged: _isUpdatingMute
                      ? null
                      : (value) async {
                          setState(() => _isUpdatingMute = true);
                          try {
                            final success = await setMute(mute: value);
                            if (!success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'audio_controls.mute_error'.tr(),
                                  ),
                                  backgroundColor: context.colors.error,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isUpdatingMute = false);
                            }
                          }
                        },
                ),
              ],
            ),

            // Status info
            if (_isUpdatingVolume || _isUpdatingMute)
              Padding(
                padding: EdgeInsets.only(top: context.spacing.gapMd),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: context.spacing.gapMd),
                    Text(
                      'audio_controls.updating'.tr(),
                      style: context.theme.textTheme.bodySmall?.copyWith(
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
