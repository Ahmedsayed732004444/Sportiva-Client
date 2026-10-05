enum PayMethod {
  card('Card'),
  wallet('Wallet');

  const PayMethod(this.apiName);
  final String apiName;

  static PayMethod? fromApi(Object? value) => PayMethod.values.where((m) => m.apiName == value.toString()).firstOrNull;
}

// The page where a fee is paid (opened in the browser) and the payment to follow afterwards.
class PaymentSession {
  const PaymentSession({required this.checkoutUrl, required this.paymentId});

  final String checkoutUrl;
  final String paymentId;

  factory PaymentSession.fromJson(Map<String, dynamic> json) =>
      PaymentSession(checkoutUrl: json['checkoutUrl'] as String, paymentId: json['paymentId'] as String);
}

enum PaymentOutcome {
  pending,
  succeeded,
  failed,
  expired,
  refunded;

  static PaymentOutcome fromApi(Object? value) => switch (value.toString()) {
    'Succeeded' => succeeded,
    'Failed' => failed,
    'Expired' => expired,
    'Refunded' => refunded,
    _ => pending,
  };

  bool get isFinal => this != pending;
}
