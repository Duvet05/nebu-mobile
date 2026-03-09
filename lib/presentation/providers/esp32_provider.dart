import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_provider.dart';

// Provider para el estado actual del volumen del ESP32
final esp32VolumeProvider = Provider<int?>((ref) {
  final serviceAsync = ref.watch(esp32WifiConfigServiceProvider);
  return serviceAsync.value?.volume;
});

// Provider para el estado actual de mute del ESP32
final esp32MuteProvider = Provider<bool?>((ref) {
  final serviceAsync = ref.watch(esp32WifiConfigServiceProvider);
  return serviceAsync.value?.isMuted;
});

// Provider para establecer el volumen del ESP32
final esp32SetVolumeProvider = Provider<Future<bool> Function(int)>((ref) {
  final serviceAsync = ref.watch(esp32WifiConfigServiceProvider);
  final service = serviceAsync.value;
  if (service == null) {
    return (_) async => false;
  }
  return service.setVolume;
});

// Provider para establecer el estado de mute del ESP32
final esp32SetMuteProvider =
    Provider<Future<bool> Function({required bool mute})>((ref) {
      final serviceAsync = ref.watch(esp32WifiConfigServiceProvider);
      final service = serviceAsync.value;
      if (service == null) {
        return ({required bool mute}) async => false;
      }
      return service.setMute;
    });
