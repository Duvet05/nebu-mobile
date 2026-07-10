import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/storage_keys.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

final localAvatarProvider = FutureProvider<String?>((ref) async {
  final userId = ref.watch(authProvider).value?.id;
  if (userId == null) {
    return null;
  }
  final storage = ref.watch(secureStorageProvider);
  return storage.read(key: StorageKeys.scoped(StorageKeys.localAvatar, userId));
});
