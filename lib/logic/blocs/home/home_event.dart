part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

final class HomeInitialEvent extends HomeEvent {}

final class HomeLoadReceiptsEvent extends HomeEvent {}

final class HomeNavigateToFileExplorerEvent extends HomeEvent {}

// The following events are placeholders for future features

final class HomeNavigateToSearchEvent extends HomeEvent {}

final class HomeNavigateToSettingsEvent extends HomeEvent {}