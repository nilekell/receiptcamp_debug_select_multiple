import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'explorer_event.dart';
part 'explorer_state.dart';

class ExplorerBloc extends Bloc<ExplorerEvent, ExplorerState> {
  ExplorerBloc() : super(ExplorerInitialState()) {
    on<ExplorerInitialEvent>(explorerInitialEvent);
    on<ExplorerNavigateToHomeEvent>(explorerNavigateToHomeEvent);
  }

  FutureOr<void> explorerInitialEvent(ExplorerInitialEvent event, Emitter<ExplorerState> emit) {
    print('explorerInitialEvent');
  }

  FutureOr<void> explorerNavigateToHomeEvent(ExplorerNavigateToHomeEvent event, Emitter<ExplorerState> emit) {
    print('homeNavigateToFileExplorerEvent');
      emit(ExplorerNavigateToHomeState());
  }
}
