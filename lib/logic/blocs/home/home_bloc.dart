import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitialState()) {
    on<HomeInitialEvent>(homeInitialEvent);
    on<HomeNavigateToFileExplorerEvent>(homeNavigateToFileExplorerEvent);
  }

  FutureOr<void> homeInitialEvent(
      HomeInitialEvent event, Emitter<HomeState> emit) {
    print('homeInitialEvent');
  }

  FutureOr<void> homeNavigateToFileExplorerEvent(HomeNavigateToFileExplorerEvent event, Emitter<HomeState> emit) {
    print('homeNavigateToFileExplorerEvent');
    emit(HomeNavigateToFileExplorerState());
    }
}
