import 'package:hive/hive.dart';

part 'payment_model.g.dart';

@HiveType(typeId: 0)
class PaymentModel extends HiveObject {
  @HiveField(0)
  final String transactionId;

  @HiveField(1)
  final String orderId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final String paymentMethod;

  @HiveField(5)
  final String paymentStatus;

  @HiveField(6)
  final DateTime paymentDate;

  @HiveField(7)
  final String? failureReason;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  /// Comma-separated product names, e.g. "Tomato ×2, Milk ×1"
  /// Added in field 10 — old records will read this as null safely.
  @HiveField(10)
  final String? itemsSummary;

  PaymentModel({
    required this.transactionId,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentDate,
    this.failureReason,
    required this.createdAt,
    required this.updatedAt,
    this.itemsSummary,
  });

  PaymentModel copyWith({
    String? transactionId,
    String? orderId,
    String? userId,
    double? amount,
    String? paymentMethod,
    String? paymentStatus,
    DateTime? paymentDate,
    String? failureReason,
    bool clearFailureReason = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? itemsSummary,
  }) {
    return PaymentModel(
      transactionId: transactionId ?? this.transactionId,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentDate: paymentDate ?? this.paymentDate,
      failureReason: clearFailureReason ? null : (failureReason ?? this.failureReason),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      itemsSummary: itemsSummary ?? this.itemsSummary,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'orderId': orderId,
      'userId': userId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paymentDate': paymentDate.toIso8601String(),
      'failureReason': failureReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'itemsSummary': itemsSummary,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      transactionId: map['transactionId'] as String,
      orderId: map['orderId'] as String,
      userId: map['userId'] as String,
      amount: (map['amount'] as num).toDouble(),
      paymentMethod: map['paymentMethod'] as String,
      paymentStatus: map['paymentStatus'] as String,
      paymentDate: DateTime.parse(map['paymentDate'] as String),
      failureReason: map['failureReason'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      itemsSummary: map['itemsSummary'] as String?,
    );
  }

  @override
  String toString() {
    return 'PaymentModel('
        'transactionId: $transactionId, '
        'orderId: $orderId, '
        'userId: $userId, '
        'amount: $amount, '
        'paymentMethod: $paymentMethod, '
        'paymentStatus: $paymentStatus, '
        'paymentDate: $paymentDate, '
        'failureReason: $failureReason, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentModel &&
          runtimeType == other.runtimeType &&
          transactionId == other.transactionId;

  @override
  int get hashCode => transactionId.hashCode;
}
