part of 'purchases_cubit.dart';

sealed class PurchasesState extends Equatable {
  const PurchasesState();

  @override
  List<Object> get props => [];
}

final class PurchasesInitial extends PurchasesState {}

final class PurchasesPending extends PurchasesState {}

final class PurchasesSuccess extends PurchasesState {}

final class PurchasesFailed extends PurchasesState {}

final class PurchasesUserStatus extends PurchasesState {
  final bool isPro;

  const PurchasesUserStatus({required this.isPro});

  @override
  List<Object> get props => [isPro];
}

final class PurchasesRestoreSuccess extends PurchasesState {}

final class PurchasesRestoreFailed extends PurchasesState {}

final class UserIsAlreadyPro extends PurchasesState {}


