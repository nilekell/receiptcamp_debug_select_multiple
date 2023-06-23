part of 'explorer_bloc.dart';

sealed class ExplorerEvent extends Equatable {
  const ExplorerEvent();

  @override
  List<Object> get props => [];
}

final class ExplorerInitialEvent extends ExplorerEvent {}

final class ExplorerFetchFilesEvent extends ExplorerEvent {}

// The following events are placeholders for future features

// final class ExplorerNavigateToSearchEvent extends ExplorerEvent {}

//final class ExplorerNavigateToSettingsEvent extends ExplorerEvent {}
