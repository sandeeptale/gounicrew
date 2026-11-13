import 'dart:math';
import 'package:hive/hive.dart';
import '../models/payment_model.dart';
import '../../domain/enums/payment_status.dart';

class PaymentRepository {
  final Box<PaymentModel> _box;

  PaymentRepository(this._box);

  String generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9000) + 1000;
    return 'TXN$timestamp$random';
  }

  String generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9000) + 1000;
    return 'ORD$timestamp$random';
  }

  Future<void> saveTransaction(PaymentModel payment) async {
    await _box.put(payment.transactionId, payment);
  }

  List<PaymentModel> getAllTransactions({String? userId}) {
    final list = _box.values.toList();
    if (userId != null && userId.isNotEmpty) {
      return list.where((p) => p.userId == userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<PaymentModel> getTransactionsByStatus(PaymentStatus status, {String? userId}) {
    var items = _box.values.where((p) => p.paymentStatus == status.storedValue);
    if (userId != null && userId.isNotEmpty) {
      items = items.where((p) => p.userId == userId);
    }
    return items.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  PaymentModel? getTransactionById(String transactionId) {
    return _box.get(transactionId);
  }

  Future<void> updateTransactionStatus(
    String transactionId,
    PaymentStatus newStatus, {
    String? failureReason,
  }) async {
    final existing = _box.get(transactionId);
    if (existing != null) {
      final updated = existing.copyWith(
        paymentStatus: newStatus.storedValue,
        failureReason: failureReason,
        clearFailureReason: failureReason == null &&
            newStatus != PaymentStatus.failed,
        updatedAt: DateTime.now(),
      );
      await _box.put(transactionId, updated);
    }
  }

  Future<void> clearAllTransactions() async {
    await _box.clear();
  }

  int get transactionCount => _box.length;
}
