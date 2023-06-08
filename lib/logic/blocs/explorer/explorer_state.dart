part of 'explorer_bloc.dart';

sealed class ExplorerState extends Equatable {
  const ExplorerState();
  
  @override
  List<Object> get props => [];
}

final class ExplorerInitialState extends ExplorerState {}

final class ExplorerActionState extends ExplorerState {}

final class ExplorerLoadingState extends ExplorerState {}

final class ExplorerLoadedSuccessState extends ExplorerState {
  const ExplorerLoadedSuccessState(this.receipts);

  final List<Receipt> receipts;
}

final class ExplorerErrorState extends ExplorerState {}

final class ExplorerNavigateToHomeState extends ExplorerActionState {}
