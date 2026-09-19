import 'package:kabadiwala_connect/app_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('controller enforces phone-only start and capture gate', () {
    final controller = AppController(enableTts: false);

    expect(controller.screen, AppScreen.welcome);
    controller.startPickup();
    expect(controller.screen, AppScreen.welcome);

    controller.setCollectorId('+919999999999');
    controller.startPickup();
    expect(controller.screen, AppScreen.capture);
    expect(controller.canContinueCapture, isFalse);
  });
}
