part of 'explorer_bloc.dart';

sealed class ExplorerEvent extends Equatable {
  // props declared when we want State to be compared against the values
  // declared inside props List
  @override
  List<Object> get props => [];
}

final class ExplorerInitialEvent extends ExplorerEvent {}

final class ExplorerFetchFilesEvent extends ExplorerEvent {
  final String folderId;
  
  ExplorerFetchFilesEvent(this.folderId);

  @override
  List<Object> get props => [folderId];
}

final class ExplorerFolderSelectedEvent extends ExplorerEvent {
  final String folderId;
  
  ExplorerFolderSelectedEvent(this.folderId);

  @override
  List<Object> get props => [folderId];
}

final class ExplorerBackNavigationEvent extends ExplorerEvent {
  final String currentFolderId;
  
  ExplorerBackNavigationEvent(this.currentFolderId);

  @override
  List<Object> get props => [currentFolderId];
}

// The following events are placeholders for future features

// final class ExplorerNavigateToSearchEvent extends ExplorerEvent {}

//final class ExplorerNavigateToSettingsEvent extends ExplorerEvent {}
