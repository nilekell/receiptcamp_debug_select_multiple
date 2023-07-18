part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object> get props => [];
}

final class HomeInitialState extends HomeState {}

final class HomeActionState extends HomeState {}

final class HomeLoadingState extends HomeState {}

final class HomeEmptyReceiptsState extends HomeState {}

final class HomeLoadedSuccessState extends HomeState {
  const HomeLoadedSuccessState({required this.receipts});

  final List<Receipt> receipts;

  @override
  List<Object> get props => [receipts];
}

final class HomeErrorState extends HomeState {}
