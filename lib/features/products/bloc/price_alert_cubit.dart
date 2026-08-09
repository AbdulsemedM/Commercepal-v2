import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import 'package:commercepal/core/auth/session_error.dart';
import '../data/repository/price_alert_repository.dart';

sealed class PriceAlertState {}

class PriceAlertInitial extends PriceAlertState {}

class PriceAlertLoading extends PriceAlertState {}

class PriceAlertActive extends PriceAlertState {
  PriceAlertActive(this.targetPrice);

  final double targetPrice;
}

class PriceAlertInactive extends PriceAlertState {}

class PriceAlertError extends PriceAlertState {
  PriceAlertError(this.message, {this.localizationKey});

  final String message;
  final String? localizationKey;
}

class PriceAlertCubit extends Cubit<PriceAlertState> {
  PriceAlertCubit({
    required this.productId,
    PriceAlertRepository? repository,
  })  : _repository = repository ?? PriceAlertRepository(),
        super(PriceAlertInitial());

  final String productId;
  final PriceAlertRepository _repository;

  Future<void> load() async {
    final double? target = await _repository.getLocalTargetPrice(productId);
    if (target != null) {
      emit(PriceAlertActive(target));
    } else {
      emit(PriceAlertInactive());
    }
  }

  Future<void> setAlert(double targetPrice) async {
    emit(PriceAlertLoading());
    try {
      await _repository.setPriceAlert(
        productId: productId,
        targetPrice: targetPrice,
      );
      emit(PriceAlertActive(targetPrice));
    } catch (e) {
      emit(_mapError(e));
    }
  }

  Future<void> removeAlert() async {
    emit(PriceAlertLoading());
    try {
      await _repository.removePriceAlert(productId: productId);
      emit(PriceAlertInactive());
    } catch (e) {
      emit(_mapError(e));
    }
  }

  PriceAlertError _mapError(Object e) {
    if (isUnauthorizedError(e)) {
      return PriceAlertError(
        'Session expired',
        localizationKey: 'checkout.sessionExpired',
      );
    }
    if (e is DioException &&
        (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout)) {
      return PriceAlertError(
        'Network error',
        localizationKey: 'priceAlert.errorNetwork',
      );
    }
    return PriceAlertError(
      'Failed',
      localizationKey: 'priceAlert.errorGeneric',
    );
  }
}
