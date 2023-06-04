part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object> get props => [];
}

class HomeInitialState extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeLoadedReceiptsState extends HomeState {
  final List<Receipt> receipts;

  const HomeLoadedReceiptsState(this.receipts);
}

class HomeSuccessState extends HomeState {}

class HomeErrorState extends HomeState {}

class HomeNavigateToFileExplorerState extends HomeState {}

// The following states are placeholders for future features

class HomeNavigateToSearchState extends HomeState {}

class HomeNavigateToSettingsState extends HomeState {}
