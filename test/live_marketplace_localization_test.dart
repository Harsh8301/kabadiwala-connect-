import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/models/workflow_models.dart';
import 'package:kabadiwala_connect/screens/live_marketplace.dart';

void main() {
  test('all six languages have live workflow labels and statuses', () {
    const languages = ['en', 'hi', 'mr', 'kn', 'te', 'bn'];
    const keys = ['signIn', 'register', 'market', 'offers', 'handovers',
      'ledger', 'batch', 'measure', 'approve', 'dispute', 'margin',
      'recycling', 'certificate', 'acceptedMaterials', 'offeredRates',
      'pickupTerms', 'paymentTerms', 'notes', 'counter', 'payment', 'image'];
    for (final language in languages) {
      for (final key in keys) {
        expect(liveText(language, key), isNotEmpty);
      }
      for (final status in ['AVAILABLE', 'PENDING', 'DISPUTED',
        'AWAITING_SELLER_APPROVAL', 'RECYCLED']) {
        expect(liveState(language, status), isNotEmpty);
      }
    }
    expect(UserRole.values, contains(UserRole.middleman));
    expect(liveText('hi', 'dispute'), isNot(liveText('en', 'dispute')));
  });
}
