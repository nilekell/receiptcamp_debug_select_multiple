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
    on<ExplorerFetchReceiptsEvent>(explorerFetchReceiptsEvent);
  }

  FutureOr<void> explorerInitialEvent(
      ExplorerInitialEvent event, Emitter<ExplorerState> emit) {
    emit(ExplorerInitialState());
    add(ExplorerFetchReceiptsEvent());
  }

  // Define fetchReceiptsEvent
  Future<FutureOr<void>> explorerFetchReceiptsEvent(
      ExplorerFetchReceiptsEvent event, Emitter<ExplorerState> emit) async {
    emit(ExplorerLoadingState());
    try {
      final List<Receipt> receipts =
          await DatabaseRepository.instance.getReceipts();
      if (receipts.isNotEmpty) {
        emit(ExplorerLoadedSuccessState(receipts));
      } else {
        emit(ExplorerEmptyReceiptsState());
      }
    } catch (error) {
      emit(ExplorerErrorState());
    }
  }
}
