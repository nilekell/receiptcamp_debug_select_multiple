import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/models/receipt.dart';
part 'explorer_event.dart';
part 'explorer_state.dart';

class ExplorerBloc extends Bloc<ExplorerEvent, ExplorerState> {
  ExplorerBloc() : super(ExplorerInitialState()) {
    on<ExplorerInitialEvent>(explorerInitialEvent);
    on<ExplorerNavigateToHomeEvent>(explorerNavigateToHomeEvent);
    on<ExplorerFetchReceiptsEvent>(fetchReceiptsEvent);
  }

  FutureOr<void> explorerInitialEvent(ExplorerInitialEvent event, Emitter<ExplorerState> emit) {
    emit(ExplorerInitialState());
    add(ExplorerFetchReceiptsEvent());
  }

  // Define fetchReceiptsEvent
Future<FutureOr<void>> fetchReceiptsEvent(ExplorerFetchReceiptsEvent event, Emitter<ExplorerState> emit) async {
  emit(ExplorerLoadingState());
  try {
    final List<Receipt> receipts = await DatabaseRepository.instance.getReceipts();
    emit(ExplorerLoadedState(receipts));
  } catch (error) {
    emit(ExplorerErrorState());
  }
}
  
  FutureOr<void> explorerNavigateToHomeEvent(ExplorerNavigateToHomeEvent event, Emitter<ExplorerState> emit) {
    emit(ExplorerNavigateToHomeState());
  }
}
