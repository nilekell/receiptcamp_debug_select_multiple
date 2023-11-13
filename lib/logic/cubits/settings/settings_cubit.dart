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
import 'package:receiptcamp/models/receipt.dart';

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
      emit(SettingsFileEmptyState());
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

  generateArchive() async {
    emit(SettingsFileLoadingState());
    try {
      final List<Receipt> allReceipts = await DatabaseRepository.instance.getAllReceiptsInFolder(rootFolderId);
      final List<Folder> allFolders = await DatabaseRepository.instance.getFolders();

      if (allReceipts.isEmpty) {
        emit(SettingsFileEmptyState());
        return;
      }

      List<Map<String, dynamic>> serializedReceipts = [];
      List<Map<String, dynamic>> serializedFolders = [];

      for (final receipt in allReceipts) {
        serializedReceipts.add(receipt.toMap());
      }

      for (final folder in allFolders) {
        serializedFolders.add(folder.toMap());
      }

       Map<String, dynamic> computeParams = {
        'serializedReceipts': serializedReceipts,
        'serializedFolders': serializedFolders,
      };

       // Prepare data to pass to isolate
      final isolateParams = IsolateParams(
        computeParams: computeParams,
        rootToken: RootIsolateToken.instance!,
      );

      final receivePort = ReceivePort();
      await Isolate.spawn(IsolateService.archiveEntryFunction, {
        'isolateParams': isolateParams,
        'sendPort': receivePort.sendPort,
      });

      // Receive data back from the isolate
      final File archiveFile = await receivePort.first;

      emit(SettingsFileArchiveLoadedState(file: archiveFile));

      } on Exception catch (e) {
      print(e.toString());
      emit(SettingsFileErrorState());
    }
  }

  shareArchive(File zipFile) async {
    try {
      FileService.shareZipFile(zipFile);
    } catch (e) {
      print(e.toString());
      emit(SettingsError());
    }
  }
    
}
