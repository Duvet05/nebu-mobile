import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

/// Keeps translation decoding inside the widget test isolate. Flutter's
/// `loadString` delegates assets larger than 50 KiB to another isolate, whose
/// completion is not driven by the widget test's fake clock.
class TestJsonAssetLoader extends AssetLoader {
  const TestJsonAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    final localePath =
        '$path/${locale.toStringWithSeparator(separator: '-')}.json';
    final data = await rootBundle.load(localePath);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final decoded = json.decode(utf8.decode(bytes));
    if (decoded case final Map<String, dynamic> translations) {
      return translations;
    }
    throw const FormatException('Translation asset must contain a JSON object');
  }
}
