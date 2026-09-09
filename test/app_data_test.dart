import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/data/app_data.dart';

void main() {
  test('seeded material prices exactly match the web prototype', () {
    expect(materials['cables']!.formalRate, 650);
    expect(materials['cables']!.informalRate, 480);
    expect(materials['pcb']!.formalRate, 220);
    expect(materials['battery']!.formalRate, 110);
    expect(materials['motor']!.formalRate, 180);
    expect(materials['crt']!.formalRate, 35);
    expect(materials['mixed']!.formalRate, 90);
    expect(materials['other']!.formalRate, 70);
  });

  test('only battery and CRT trigger hazard flow', () {
    expect(materials['battery']!.isHazardous, isTrue);
    expect(materials['crt']!.isHazardous, isTrue);
    expect(
      materials.values.where((item) => item.isHazardous).length,
      2,
    );
  });

  test('all three languages contain core navigation labels', () {
    for (final language in ['mr', 'hi', 'en']) {
      expect(textFor(language, 'start'), isNotEmpty);
      expect(textFor(language, 'confirmHandover'), isNotEmpty);
      expect(stepLabels[language], hasLength(5));
    }
  });
}
