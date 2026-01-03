class PaymentResult {
  final bool success;
  final String message;
  final String? transactionId;

  const PaymentResult({
    required this.success,
    required this.message,
    this.transactionId,
  });
}
