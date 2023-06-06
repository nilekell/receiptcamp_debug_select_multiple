part of 'explorer_bloc.dart';

abstract class ExplorerState extends Equatable {
  const ExplorerState();
  
  @override
  List<Object> get props => [];
}

class ExplorerInitialState extends ExplorerState {}

class ExplorerLoadingState extends ExplorerState {}

class ExplorerLoadedState extends ExplorerState {
  const ExplorerLoadedState(this.receipts);

  final List<Receipt> receipts;
}


class ExplorerSuccessState extends ExplorerState {}

class ExplorerErrorState extends ExplorerState {}

class ExplorerNavigateToHomeState extends ExplorerState {}
