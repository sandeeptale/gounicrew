import 'package:equatable/equatable.dart';
import '../../data/models/payment_model.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();

  @override
  List<Object?> get props => [];
}

class PaymentProcessing extends PaymentState {
  final String orderId;
  final double amount;
  final String paymentMethod;
  final String transactionId;

  const PaymentProcessing({
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.transactionId,
  });

  @override
  List<Object?> get props => [orderId, amount, paymentMethod, transactionId];
}

class PaymentSuccess extends PaymentState {
  final PaymentModel payment;

  const PaymentSuccess({required this.payment});

  @override
  List<Object?> get props => [payment];
}

class PaymentFailure extends PaymentState {
  final PaymentModel payment;
  final String reason;

  const PaymentFailure({required this.payment, required this.reason});

  @override
  List<Object?> get props => [payment, reason];
}

class PaymentPending extends PaymentState {
  final PaymentModel payment;

  const PaymentPending({required this.payment});

  @override
  List<Object?> get props => [payment];
}

class PaymentCancelled extends PaymentState {
  final PaymentModel payment;

  const PaymentCancelled({required this.payment});

  @override
  List<Object?> get props => [payment];
}

class PaymentHistoryLoading extends PaymentState {
  const PaymentHistoryLoading();

  @override
  List<Object?> get props => [];
}

class PaymentHistoryLoaded extends PaymentState {
  final List<PaymentModel> transactions;
  final String filter; // 'all', 'success', 'failed', 'pending', 'cancelled'

  List<PaymentModel> get payments => transactions;

  const PaymentHistoryLoaded({
    required this.transactions,
    required this.filter,
  });

  @override
  List<Object?> get props => [transactions, filter];
}

class PaymentHistoryError extends PaymentState {
  final String message;

  const PaymentHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
