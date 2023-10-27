import 'dart:io';
import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:receiptcamp/data/data_constants.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/data/services/isolate.dart';
import 'package:receiptcamp/data/utils/file_helper.dart';
import 'package:receiptcamp/models/folder.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial());

  init() {
    emit(SettingsInitial());
    emit(SettingsLoading());
    emit(SettingsSuccess());
  }

  generateZipFile() async {
    emit(SettingsFileLoadingState());
    try {

    final folder = await DatabaseRepository.instance.getFolderById(rootFolderId);    
    final folderIsEmpty = await DatabaseRepository.instance.folderIsEmpty(rootFolderId);
    
    if (folderIsEmpty) {
      return;
    }
      Map<String, dynamic> serializedFolder = folder.toMap();

      Map<String, dynamic> computeParams = {
        'folder': serializedFolder,
        'withPdfs': false
      };

      // Prepare data to pass to isolate
      final isolateParams = IsolateParams(
        computeParams: computeParams,
        rootToken: RootIsolateToken.instance!,
      );

      final receivePort = ReceivePort();
      await Isolate.spawn(IsolateService.zipFileEntryFunction, {
        'isolateParams': isolateParams,
        'sendPort': receivePort.sendPort,
      });

      // Receive data back from the isolate
      final File zipFile = await receivePort.first;

      emit(SettingsFileLoadedState(file: zipFile, folder: folder));
    } on Exception catch (e) {
      print(e.toString());
      emit(SettingsFileErrorState());
    }
  }

  // share folder
  shareFolder(Folder folder, File zipFile) async {
    try {
      await FileService.shareFolderAsZip(folder, zipFile);
    } on Exception catch (e) {
      print(e.toString());
      emit(SettingsError());
    }
  }

}
