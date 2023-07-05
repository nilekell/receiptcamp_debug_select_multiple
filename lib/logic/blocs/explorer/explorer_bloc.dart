import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/models/folder.dart';

part 'explorer_event.dart';
part 'explorer_state.dart';

class ExplorerBloc extends Bloc<ExplorerEvent, ExplorerState> {
  ExplorerBloc() : super(ExplorerInitialState()) {
    on<ExplorerInitialEvent>(explorerInitialEvent);
    on<ExplorerFetchFilesEvent>(explorerFetchFilesEvent);
    on<ExplorerFolderSelectedEvent>(explorerFolderSelectedEvent);
    on<ExplorerBackNavigationEvent>(explorerBackNavigationEvent);
  }

  FutureOr<void> explorerInitialEvent(
      ExplorerInitialEvent event, Emitter<ExplorerState> emit) {
    emit(ExplorerInitialState());
    add(ExplorerFetchFilesEvent('a1'));
  }

  FutureOr<void> explorerFetchFilesEvent(
      ExplorerFetchFilesEvent event, Emitter<ExplorerState> emit) async {
    emit(ExplorerLoadingState());
    try {
      final List<Object> files = await DatabaseRepository.instance.getFolderContents(event.folderId);
      if (files.isNotEmpty) {
        emit(ExplorerLoadedSuccessState(files: files));
      } else {
        emit(ExplorerEmptyFilesState());
      }
    } catch (error) {
      emit(ExplorerErrorState());
    }
  }

  FutureOr<void> explorerFolderSelectedEvent(
      ExplorerFolderSelectedEvent event, Emitter<ExplorerState> emit) async {
    emit(ExplorerLoadingState());
    try {
      final List<Object> files = await DatabaseRepository.instance.getFolderContents(event.folderId);
      if (files.isNotEmpty) {
        emit(ExplorerLoadedSuccessState(files: files));
      } else {
        emit(ExplorerEmptyFilesState());
      }
    } catch (error) {
      emit(ExplorerErrorState());
    }
  }

  static FutureOr<void> explorerBackNavigationEvent(
      ExplorerBackNavigationEvent event, Emitter<ExplorerState> emit) async {
    emit(ExplorerLoadingState());
    try {
      final Folder parentFolder = await DatabaseRepository.instance.getFolderById(event.currentFolderId);
      final List<Object> files = await DatabaseRepository.instance.getFolderContents(parentFolder.parentId);
      if (files.isNotEmpty) {
        emit(ExplorerLoadedSuccessState(files: files));
      } else {
        emit(ExplorerEmptyFilesState());
      }
    } catch (error) {
      emit(ExplorerErrorState());
    }
  }
}

