import 'package:flutter_test/flutter_test.dart';
import 'package:sportiva_app/features/payments/data/payment_models.dart';

void main() {
  test('a payment session carries the page to pay on and the payment to follow', () {
    final session = PaymentSession.fromJson({
      'paymentId': 'p1',
      'checkoutUrl': 'https://pay/x',
      'expiresAt': '2026-10-06T10:00:00Z',
    });
    expect((session.paymentId, session.checkoutUrl), ('p1', 'https://pay/x'));
  });

  test('only final outcomes are announced to the user', () {
    expect(PaymentOutcome.fromApi('Pending').isFinal, isFalse);
    for (final value in ['Succeeded', 'Failed', 'Expired', 'Refunded']) {
      expect(PaymentOutcome.fromApi(value).isFinal, isTrue, reason: value);
    }
    expect(PaymentOutcome.fromApi('???'), PaymentOutcome.pending);
  });

  test('the ways to pay are read by name and unknown ones are skipped', () {
    expect(PayMethod.fromApi('Card'), PayMethod.card);
    expect(PayMethod.fromApi('Wallet'), PayMethod.wallet);
    expect(PayMethod.fromApi('Cash'), isNull);
  });
}
