import 'package:flutter/material.dart';

class NebuVoiceOption {
  const NebuVoiceOption({
    required this.id,
    required this.labelKey,
    required this.descriptionKey,
    required this.icon,
  });

  final String id;
  final String labelKey;
  final String descriptionKey;
  final IconData icon;
}

const nebuVoiceOptions = <NebuVoiceOption>[
  NebuVoiceOption(
    id: 'default-oklrorszoxbwzfdj8zjhng__nebu',
    labelKey: 'setup.voice.nebu_lyra',
    descriptionKey: 'setup.voice.nebu_lyra_desc',
    icon: Icons.auto_awesome,
  ),
  NebuVoiceOption(
    id: 'default-oklrorszoxbwzfdj8zjhng__nebu_cat2',
    labelKey: 'setup.voice.nebu_dash',
    descriptionKey: 'setup.voice.nebu_dash_desc',
    icon: Icons.bolt_rounded,
  ),
  NebuVoiceOption(
    id: 'default-oklrorszoxbwzfdj8zjhng__nebucherry',
    labelKey: 'setup.voice.nebu_cherry',
    descriptionKey: 'setup.voice.nebu_cherry_desc',
    icon: Icons.favorite_rounded,
  ),
  NebuVoiceOption(
    id: 'default-oklrorszoxbwzfdj8zjhng__nebu_nino',
    labelKey: 'setup.voice.nebu_pixel',
    descriptionKey: 'setup.voice.nebu_pixel_desc',
    icon: Icons.videogame_asset_rounded,
  ),
  NebuVoiceOption(
    id: 'default-oklrorszoxbwzfdj8zjhng__nebu_pirat',
    labelKey: 'setup.voice.nebu_orion',
    descriptionKey: 'setup.voice.nebu_orion_desc',
    icon: Icons.explore_rounded,
  ),
];

NebuVoiceOption? findNebuVoiceOption(String? voiceId) {
  if (voiceId == null || voiceId.isEmpty) {
    return null;
  }
  for (final option in nebuVoiceOptions) {
    if (option.id == voiceId) {
      return option;
    }
  }
  return null;
}
