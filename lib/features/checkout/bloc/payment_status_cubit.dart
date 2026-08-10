import 'dart:async';

import 'package:bloc/bloc.dart';

import '../data/models/payment_status_result.dart';
import '../data/repository/payment_status_repository.dart';

sealed class PaymentStatusState {}

class PaymentStatusInitial extends PaymentStatusState {}

class PaymentStatusPolling extends PaymentStatusState {
  PaymentStatusPolling({required this.attempt, this.lastStatus});

  final int attempt;
  final String? lastStatus;
}

class PaymentStatusSuccess extends PaymentStatusState {
  PaymentStatusSuccess(this.result);

  final PaymentStatusResult result;
}

class PaymentStatusFailed extends PaymentStatusState {
  PaymentStatusFailed(this.result);

  final PaymentStatusResult result;
}

class PaymentStatusTimeout extends PaymentStatusState {}

class PaymentStatusCubit extends Cubit<PaymentStatusState> {
  PaymentStatusCubit({PaymentStatusRepository? repository})
      : _repository = repository ?? PaymentStatusRepository(),
        super(PaymentStatusInitial());

  static const int maxAttempts = 360;
  static const Duration pollInterval = Duration(seconds: 5);

  final PaymentStatusRepository _repository;
  Timer? _timer;
  String? _orderNumber;
  int _attempt = 0;

  void stopPolling() {
    _timer?.cancel();
  }

  /// Immediate status check (e.g. on app resume).
  Future<void> checkNow() async {
    if (_orderNumber == null || _orderNumber!.isEmpty) return;
    await _pollOnce();
  }

  void startPolling(String orderNumber) {
    if (orderNumber.trim().isEmpty) return;
    _orderNumber = orderNumber.trim();
    _attempt = 0;
    _timer?.cancel();
    emit(PaymentStatusPolling(attempt: 0));
    unawaited(_pollOnce());
    _timer = Timer.periodic(pollInterval, (_) => unawaited(_pollOnce()));
  }

  Future<void> _pollOnce() async {
    final String? orderNumber = _orderNumber;
    if (orderNumber == null || orderNumber.isEmpty || isClosed) return;

    if (_attempt >= maxAttempts) {
      _timer?.cancel();
      emit(PaymentStatusTimeout());
      return;
    }

    _attempt++;
    emit(PaymentStatusPolling(attempt: _attempt));

    try {
      final PaymentStatusResult result =
          await _repository.getPaymentStatus(orderNumber);
      if (isClosed) return;

      if (result.isSuccess) {
        _timer?.cancel();
        emit(PaymentStatusSuccess(result));
        return;
      }
      if (result.isFailed) {
        _timer?.cancel();
        emit(PaymentStatusFailed(result));
        return;
      }

      emit(
        PaymentStatusPolling(
          attempt: _attempt,
          lastStatus: result.paymentStatus,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        PaymentStatusPolling(
          attempt: _attempt,
          lastStatus: state is PaymentStatusPolling
              ? (state as PaymentStatusPolling).lastStatus
              : null,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
