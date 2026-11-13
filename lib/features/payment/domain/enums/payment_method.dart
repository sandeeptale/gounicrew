import 'package:flutter/material.dart';

enum PaymentMethod {
  upi,
  creditCard,
  debitCard,
  netBanking,
  cashOnDelivery,
  wallet,
}

extension PaymentMethodX on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.netBanking:
        return 'Net Banking';
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentMethod.wallet:
        return 'Wallet';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.upi:
        return Icons.account_balance_wallet_outlined;
      case PaymentMethod.creditCard:
        return Icons.credit_card_outlined;
      case PaymentMethod.debitCard:
        return Icons.payment_outlined;
      case PaymentMethod.netBanking:
        return Icons.account_balance_outlined;
      case PaymentMethod.cashOnDelivery:
        return Icons.local_shipping_outlined;
      case PaymentMethod.wallet:
        return Icons.wallet_outlined;
    }
  }

  String get storedValue => name;
}

PaymentMethod paymentMethodFromString(String value) {
  return PaymentMethod.values.firstWhere(
    (e) => e.name == value,
    orElse: () => PaymentMethod.upi,
  );
}
