/// Client-side profanity filter for user-generated names.
abstract final class ContentFilter {
  ContentFilter._();

  /// Returns true if [text] contains a banned word (word-boundary matching).
  static bool containsProfanity(String text) =>
      _pattern.hasMatch(text.toLowerCase().trim());

  static const _bannedWords = <String>[
    // EN slurs
    'nigger', 'nigga', 'chink', 'spic', 'wetback', 'kike', 'beaner',
    'faggot', 'retard',
    // EN profanity
    'fuck', 'shit', 'cunt', 'whore', 'slut',
    // ES slurs
    'marica', 'maricon',
    // ES profanity
    'puta', 'puto', 'pendejo', 'pendeja',
    'mierda', 'verga', 'chingada',
    'culero', 'culera', 'hijueputa',
  ];

  /// Precompiled regex with word boundaries to avoid false positives.
  static final _pattern = RegExp(
    _bannedWords.map((w) => '(?<![a-z])${RegExp.escape(w)}(?![a-z])').join('|'),
  );
}
