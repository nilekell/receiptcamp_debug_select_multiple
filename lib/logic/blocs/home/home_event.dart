part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeInitialEvent extends HomeEvent {}

class HomeLoadReceiptsEvent extends HomeEvent {}

class HomeNavigateToHomeEvent extends HomeEvent {
  const HomeNavigateToHomeEvent({required this.context});
  final BuildContext context;

  @override
  List<Object> get props => [context];
}

class HomeNavigateToFileExplorerEvent extends HomeEvent {}

// The following events are placeholders for future features

class HomeNavigateToSearchEvent extends HomeEvent {}

class HomeNavigateToSettingsEvent extends HomeEvent {}