part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object> get props => [];
}

final class HomeInitialState extends HomeState {}

final class HomeLoadingState extends HomeState {}

final class HomeLoadedReceiptsState extends HomeState {
  final List<Receipt> receipts;

  const HomeLoadedReceiptsState(this.receipts);
}

// final class HomeSuccessState extends HomeState {}

final class HomeErrorState extends HomeState {}

final class HomeNavigateToFileExplorerState extends HomeState {}

// The following states are placeholders for future features

// final class HomeNavigateToSearchState extends HomeState {}

// final class HomeNavigateToSettingsState extends HomeState {}
