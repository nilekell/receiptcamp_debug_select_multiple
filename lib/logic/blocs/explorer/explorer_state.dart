part of 'explorer_bloc.dart';

sealed class ExplorerState extends Equatable {
  const ExplorerState();
  
  @override
  List<Object> get props => [];
}

final class ExplorerInitialState extends ExplorerState {}

final class ExplorerLoadingState extends ExplorerState {}

final class ExplorerLoadedSuccessState extends ExplorerState {
  final List<Object> files;

  const ExplorerLoadedSuccessState({required this.files});

  @override
  List<Object> get props => [files];
}

final class ExplorerEmptyFilesState extends ExplorerState {}

final class ExplorerErrorState extends ExplorerState {}

