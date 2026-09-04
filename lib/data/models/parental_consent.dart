/// Versioned declarations required before enabling a child's voice experience.
class ParentalConsent {
  const ParentalConsent({required this.locale});

  static const currentPrivacyVersion = '2026-08-05';
  static const supportedLocales = {'de', 'en', 'es', 'pt'};

  final String locale;

  Map<String, dynamic> toJson() => {
    'parentOrGuardianDeclaration': true,
    'childDataProcessing': true,
    'sensitiveDataProcessing': true,
    'privacyVersion': currentPrivacyVersion,
    'locale': supportedLocales.contains(locale) ? locale : 'en',
  };

  static bool isCurrentRecord(Object? value, {required String userId}) {
    if (value is! Map) {
      return false;
    }

    return value['parentOrGuardianDeclaration'] == true &&
        value['childDataProcessing'] == true &&
        value['sensitiveDataProcessing'] == true &&
        value['privacyVersion'] == currentPrivacyVersion &&
        value['authenticatedUserId'] == userId;
  }
}
