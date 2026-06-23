import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:nebu_mobile_flutter/core/errors/app_exception.dart';
import 'package:nebu_mobile_flutter/data/models/toy.dart';
import 'package:nebu_mobile_flutter/data/services/toy_service.dart';
import 'mocks.dart';

void main() {
  late MockApiService apiService;
  late MockLogger logger;
  late ToyService toyService;

  setUp(() {
    apiService = MockApiService();
    logger = MockLogger();
    toyService = ToyService(apiService: apiService, logger: logger);
  });

  test('createToy crea un juguete y lo parsea correctamente', () async {
    when(
      apiService.post<Map<String, dynamic>>(
        '/toys',
        data: anyNamed('data') as Object?,
      ),
    ).thenAnswer(
      (_) async => <String, dynamic>{
        'id': 'toy-1',
        'name': 'Dino',
        'status': 'active',
      },
    );

    final toy = await toyService.createToy(name: 'Dino');

    expect(toy.id, 'toy-1');
    expect(toy.name, 'Dino');
    expect(toy.status, ToyStatus.active);
  });

  test('getMyToys retorna lista vacía ante NotFoundException', () async {
    when(
      apiService.get<List<dynamic>>('/toys/my-toys'),
    ).thenThrow(const NotFoundException('No toys'));

    final toys = await toyService.getMyToys();

    expect(toys, isEmpty);
  });

  test(
    'updateToyConnectionStatus propaga AppException desde ApiService',
    () async {
      when(
        apiService.patch<Map<String, dynamic>>(
          '/toys/connection/device-1',
          data: anyNamed('data') as Object?,
        ),
      ).thenThrow(
        const ValidationException('Invalid payload', statusCode: 400),
      );

      await expectLater(
        () => toyService.updateToyConnectionStatus(
          deviceId: 'device-1',
          status: ToyStatus.connected,
        ),
        throwsA(isA<ValidationException>()),
      );
    },
  );
}
