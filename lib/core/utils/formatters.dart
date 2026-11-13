import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  /// Returns a formatted currency string like "₹1,299.00"
  static String formatCurrency(double amount) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    return '₹${formatter.format(amount)}';
  }

  /// Returns a formatted date string like "12 Nov 2026, 11:30 PM"
  static String formatDate(DateTime dt) {
    return DateFormat('d MMM yyyy, hh:mm a').format(dt);
  }

  /// Returns a truncated transaction ID with "..." prefix showing last 8 chars.
  /// Example: "TXN1731435678901234" → "...78901234"
  static String formatTransactionId(String id) {
    if (id.length <= 8) return id;
    return '...${id.substring(id.length - 8)}';
  }

  /// Converts stored payment method enum name to a human-readable string.
  /// Falls back to capitalizing the string if no match is found.
  static String formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'upi':
        return 'UPI';
      case 'creditcard':
        return 'Credit Card';
      case 'debitcard':
        return 'Debit Card';
      case 'netbanking':
        return 'Net Banking';
      case 'cashondelivery':
        return 'Cash on Delivery';
      case 'wallet':
        return 'Wallet';
      default:
        if (method.isEmpty) return 'Unknown';
        return method[0].toUpperCase() + method.substring(1);
    }
  }
}

/// Returns a formatted currency string like "₹1,299.00"
String formatCurrency(double amount) => Formatters.formatCurrency(amount);

/// Returns a formatted date string like "12 Nov 2026, 11:30 PM"
String formatDate(DateTime dt) => Formatters.formatDate(dt);

/// Returns a truncated transaction ID with "..." prefix showing last 8 chars.
String formatTransactionId(String id) => Formatters.formatTransactionId(id);

/// Converts stored payment method enum name to a human-readable string.
String formatPaymentMethod(String method) => Formatters.formatPaymentMethod(method);
