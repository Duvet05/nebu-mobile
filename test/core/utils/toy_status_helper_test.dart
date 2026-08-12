import 'package:flutter_test/flutter_test.dart';

import 'package:nebu_mobile_flutter/core/utils/toy_status_helper.dart';
import 'package:nebu_mobile_flutter/data/models/toy.dart';

Toy _toy({required ToyStatus status, String? iotDeviceStatus}) => Toy(
  id: 'toy-1',
  name: 'Dino',
  status: status,
  iotDeviceStatus: iotDeviceStatus,
);

void main() {
  group('ToyPresenceUI.displayStatus', () {
    test('iotDeviceStatus online gana sobre un status inactive', () {
      final toy = _toy(status: ToyStatus.inactive, iotDeviceStatus: 'online');
      expect(toy.displayStatus, ToyStatus.connected);
      expect(toy.displayStatus.isOnline, isTrue);
    });

    test('iotDeviceStatus offline gana sobre un status active', () {
      final toy = _toy(status: ToyStatus.active, iotDeviceStatus: 'offline');
      expect(toy.displayStatus, ToyStatus.disconnected);
      expect(toy.displayStatus.isOnline, isFalse);
    });

    test('sin iotDeviceStatus se conserva el status del backend', () {
      expect(_toy(status: ToyStatus.active).displayStatus, ToyStatus.active);
      expect(
        _toy(status: ToyStatus.disconnected).displayStatus,
        ToyStatus.disconnected,
      );
    });

    test('estados de ciclo de vida no se enmascaran aunque el device '
        'reporte online', () {
      for (final status in [
        ToyStatus.pending,
        ToyStatus.blocked,
        ToyStatus.error,
        ToyStatus.maintenance,
      ]) {
        final toy = _toy(status: status, iotDeviceStatus: 'online');
        expect(toy.displayStatus, status);
      }
    });

    test('un valor desconocido de iotDeviceStatus no altera el status', () {
      final toy = _toy(status: ToyStatus.active, iotDeviceStatus: 'sleeping');
      expect(toy.displayStatus, ToyStatus.active);
    });
  });
}
