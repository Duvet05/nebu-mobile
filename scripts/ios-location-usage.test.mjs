import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const localeExpectations = {
  en: [/name of your current Wi-Fi network/i, /optional/i, /manually/i],
  es: [/nombre de tu red Wi-Fi actual/i, /opcional/i, /manualmente/i],
  pt: [/nome da sua rede Wi-Fi atual/i, /opcional/i, /manualmente/i],
};

for (const [locale, expected] of Object.entries(localeExpectations)) {
  test(`${locale}: location explains optional current Wi-Fi name access`, () => {
    const strings = readFileSync(
      new URL(`../ios/Runner/${locale}.lproj/InfoPlist.strings`, import.meta.url),
      'utf8',
    );
    const matches = [...strings.matchAll(
      /^"NSLocationWhenInUseUsageDescription"\s*=\s*"([^"\r\n]+)";$/gm,
    )];
    assert.equal(matches.length, 1, 'One localized location purpose is required');
    const purpose = matches[0][1];
    for (const pattern of expected) assert.match(purpose, pattern);
    assert.doesNotMatch(purpose, /Bluetooth/i);
  });
}
