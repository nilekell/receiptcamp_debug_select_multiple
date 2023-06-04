part of 'explorer_bloc.dart';

abstract class ExplorerEvent extends Equatable {
  const ExplorerEvent();

  @override
  List<Object> get props => [];
}

class ExplorerInitialEvent extends ExplorerEvent {}

class ExplorerNavigateToHomeEvent extends ExplorerEvent {
  const ExplorerNavigateToHomeEvent({required this.context});

  final BuildContext context;

  @override
  List<Object> get props => [context];
}

// The following events are placeholders for future features

class ExplorerNavigateToSearchEvent extends ExplorerEvent {}

class ExplorerNavigateToSettingsEvent extends ExplorerEvent {}
