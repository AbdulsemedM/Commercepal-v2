part of 'affiliate_register_cubit.dart';

@immutable
sealed class AffiliateRegisterState {}

final class AffiliateRegisterInitial extends AffiliateRegisterState {}

final class AffiliateRegisterLoading extends AffiliateRegisterState {}

final class AffiliateRegisterSuccess extends AffiliateRegisterState {}

final class AffiliateRegisterFailure extends AffiliateRegisterState {
  final String message;

  AffiliateRegisterFailure(this.message);
}
