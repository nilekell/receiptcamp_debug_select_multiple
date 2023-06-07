part of 'explorer_bloc.dart';

sealed class ExplorerState extends Equatable {
  const ExplorerState();
  
  @override
  List<Object> get props => [];
}

final class ExplorerInitialState extends ExplorerState {}

final class ExplorerLoadingState extends ExplorerState {}

final class ExplorerLoadedState extends ExplorerState {
  const ExplorerLoadedState(this.receipts);

  final List<Receipt> receipts;
}


// final class ExplorerSuccessState extends ExplorerState {}

final class ExplorerErrorState extends ExplorerState {}

final class ExplorerNavigateToHomeState extends ExplorerState {}
