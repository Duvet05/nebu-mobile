import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:nebu_mobile_flutter/data/services/api_service.dart';

@GenerateNiceMocks([
  MockSpec<FlutterSecureStorage>(),
  MockSpec<ApiService>(),
  MockSpec<Logger>(),
])
// ignore: unused_import
import 'mocks.mocks.dart';
export 'mocks.mocks.dart';
