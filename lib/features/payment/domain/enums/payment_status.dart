import 'package:flutter/material.dart';

enum PaymentStatus {
  success,
  failed,
  pending,
  cancelled,
}

extension PaymentStatusX on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.success:
        return 'Success';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.success:
        return const Color(0xFF4CAF82);
      case PaymentStatus.failed:
        return const Color(0xFFE53935);
      case PaymentStatus.pending:
        return const Color(0xFFF59E0B);
      case PaymentStatus.cancelled:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentStatus.success:
        return Icons.check_circle_outline_rounded;
      case PaymentStatus.failed:
        return Icons.cancel_outlined;
      case PaymentStatus.pending:
        return Icons.hourglass_empty_rounded;
      case PaymentStatus.cancelled:
        return Icons.remove_circle_outline_rounded;
    }
  }

  String get storedValue => name;
}

PaymentStatus paymentStatusFromString(String value) {
  return PaymentStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => PaymentStatus.pending,
  );
}
