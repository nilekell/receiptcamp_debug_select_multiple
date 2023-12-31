import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/models/receipt.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final DatabaseRepository databaseRepository;

  HomeBloc({required this.databaseRepository}) : super(HomeInitialState()) {
    on<HomeLoadReceiptsEvent>(onHomeLoadReceipts);
    on<HomeInitialEvent>(onHomeInitialEvent);
  }

  FutureOr<void> onHomeInitialEvent(
      HomeInitialEvent event, Emitter<HomeState> emit) {
    emit(HomeLoadingState());
    add(HomeLoadReceiptsEvent());
  }

  FutureOr<void> onHomeLoadReceipts(
      HomeLoadReceiptsEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState());
    try {
      final receipts = await databaseRepository.getRecentReceipts();
      if (receipts.isNotEmpty) {
      emit(HomeLoadedSuccessState(receipts: receipts));
    } else {
      emit(HomeEmptyReceiptsState());
    }
    } catch (_) {
      emit(HomeErrorState());
    }
  }
}
