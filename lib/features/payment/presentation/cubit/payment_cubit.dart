import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/payment_repository.dart';
import '../../domain/enums/payment_method.dart';
import '../../domain/enums/payment_status.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository _repository;

  PaymentCubit(this._repository) : super(const PaymentInitial());

  /// Processes a payment for the given order.
  /// [testScenario] can be 'success', 'failure', 'pending', or 'cancelled'.
  Future<void> processPayment({
    required String orderId,
    required String userId,
    required double amount,
    required PaymentMethod method,
    String testScenario = 'success',
    String? itemsSummary,
  }) async {
    final transactionId = _repository.generateTransactionId();

    emit(PaymentProcessing(
      orderId: orderId,
      amount: amount,
      paymentMethod: method.displayName,
      transactionId: transactionId,
    ));

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    if (isClosed) return;

    final now = DateTime.now();
    PaymentModel payment;

    // Cash on Delivery — always succeeds with a "pending" status
    if (method == PaymentMethod.cashOnDelivery) {
      payment = PaymentModel(
        transactionId: transactionId,
        orderId: orderId,
        userId: userId,
        amount: amount,
        paymentMethod: method.storedValue,
        paymentStatus: PaymentStatus.pending.storedValue,
        paymentDate: now,
        failureReason: null,
        createdAt: now,
        updatedAt: now,
        itemsSummary: itemsSummary,
      );
      await _repository.saveTransaction(payment);
      emit(PaymentSuccess(payment: payment));
      return;
    }

    switch (testScenario) {
      case 'failure':
        payment = PaymentModel(
          transactionId: transactionId,
          orderId: orderId,
          userId: userId,
          amount: amount,
          paymentMethod: method.storedValue,
          paymentStatus: PaymentStatus.failed.storedValue,
          paymentDate: now,
          failureReason: 'Payment declined by bank. Please try again.',
          createdAt: now,
          updatedAt: now,
          itemsSummary: itemsSummary,
        );
        await _repository.saveTransaction(payment);
        emit(PaymentFailure(payment: payment, reason: payment.failureReason!));
        break;

      case 'pending':
        payment = PaymentModel(
          transactionId: transactionId,
          orderId: orderId,
          userId: userId,
          amount: amount,
          paymentMethod: method.storedValue,
          paymentStatus: PaymentStatus.pending.storedValue,
          paymentDate: now,
          failureReason: null,
          createdAt: now,
          updatedAt: now,
          itemsSummary: itemsSummary,
        );
        await _repository.saveTransaction(payment);
        emit(PaymentPending(payment: payment));
        break;

      case 'cancelled':
        payment = PaymentModel(
          transactionId: transactionId,
          orderId: orderId,
          userId: userId,
          amount: amount,
          paymentMethod: method.storedValue,
          paymentStatus: PaymentStatus.cancelled.storedValue,
          paymentDate: now,
          failureReason: null,
          createdAt: now,
          updatedAt: now,
          itemsSummary: itemsSummary,
        );
        await _repository.saveTransaction(payment);
        emit(PaymentCancelled(payment: payment));
        break;

      default: // 'success'
        payment = PaymentModel(
          transactionId: transactionId,
          orderId: orderId,
          userId: userId,
          amount: amount,
          paymentMethod: method.storedValue,
          paymentStatus: PaymentStatus.success.storedValue,
          paymentDate: now,
          failureReason: null,
          createdAt: now,
          updatedAt: now,
          itemsSummary: itemsSummary,
        );
        await _repository.saveTransaction(payment);
        emit(PaymentSuccess(payment: payment));
        break;
    }
  }

  /// Retries a payment for the same order with a new transaction ID.
  Future<void> retryPayment({
    required String orderId,
    required String userId,
    required double amount,
    required PaymentMethod method,
    String testScenario = 'success',
    String? itemsSummary,
  }) async {
    await processPayment(
      orderId: orderId,
      userId: userId,
      amount: amount,
      method: method,
      testScenario: testScenario,
      itemsSummary: itemsSummary,
    );
  }

  /// Simulates checking the status of a pending transaction.
  /// For simulation purposes, it always resolves to success.
  Future<void> checkPendingStatus(String transactionId) async {
    await Future.delayed(const Duration(seconds: 2));

    if (isClosed) return;

    final payment = _repository.getTransactionById(transactionId);
    if (payment == null) return;

    await _repository.updateTransactionStatus(
      transactionId,
      PaymentStatus.success,
    );
    final updated = _repository.getTransactionById(transactionId)!;
    emit(PaymentSuccess(payment: updated));
  }

  /// Cancels an in-progress or pending payment.
  Future<void> cancelPayment(String transactionId) async {
    await _repository.updateTransactionStatus(
      transactionId,
      PaymentStatus.cancelled,
    );

    if (isClosed) return;

    final updated = _repository.getTransactionById(transactionId)!;
    emit(PaymentCancelled(payment: updated));
  }

  /// Loads payment history, optionally filtered by status and userId.
  /// [filter] can be 'all', 'success', 'failed', 'pending', or 'cancelled'.
  Future<void> loadPaymentHistory({String filter = 'all', String? userId}) async {
    emit(const PaymentHistoryLoading());
    try {
      List<PaymentModel> transactions;
      if (filter == 'all') {
        transactions = _repository.getAllTransactions(userId: userId);
      } else {
        final status = paymentStatusFromString(filter);
        transactions = _repository.getTransactionsByStatus(status, userId: userId);
      }
      emit(PaymentHistoryLoaded(transactions: transactions, filter: filter));
    } catch (e) {
      emit(PaymentHistoryError(e.toString()));
    }
  }

  /// Resets the cubit to its initial state.
  void resetState() => emit(const PaymentInitial());
}
