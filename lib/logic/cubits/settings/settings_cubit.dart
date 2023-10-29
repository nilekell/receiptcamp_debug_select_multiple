import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:archive/archive_io.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:receiptcamp/data/data_constants.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/data/services/isolate.dart';
import 'package:receiptcamp/data/utils/file_helper.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
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
      final List<File> allImages = await FileService.getAllReceiptImages();

      // print('allReceipts.length: ${allReceipts.length}');
      // print('allFolders.length: ${allFolders.length}');
      // print('allImages.length: ${allImages.length}');

      final Archive archive = Archive();

      // adding all receipt image files to zip file
      for (final file in allImages) {
        final bytes = await file.readAsBytes();
        archive.addFile(ArchiveFile('Images/${basename(file.path)}', bytes.length, bytes));
        print('added Images/${basename(file.path)} to archive');
      }

      // adding all receipt json object files to zip file
      for (final receipt in allReceipts) {
        String receiptJson = receipt.toJson();
        final bytes = utf8.encode(receiptJson);  // Convert JSON string to bytes
        archive.addFile(ArchiveFile('Objects/Receipts/${receipt.fileName.split('.').first}.json', bytes.length, bytes));
        print('added Objects/Receipts/${receipt.fileName.split('.').first}.json to archive');
      }

      // adding all folder json object files to zip file
      for (final folder in allFolders) {
        if (folder.id == rootFolderId) {
          // changing id of root folder id
          final Folder rootFolder = Folder(id: Utility.generateUid(), name: 'Imported_Expenses', lastModified: folder.lastModified, parentId: folder.parentId);
          String folderJson = rootFolder.toJson();
          final bytes = utf8.encode(folderJson);
          archive.addFile(ArchiveFile('Objects/Folders/${rootFolder.name}.json', bytes.length, bytes));
          print('added Objects/Folders/${rootFolder.name}.json to archive');
        } else {
          String folderJson = folder.toJson();
          String fixedFolderName = Utility.concatenateWithUnderscore(folder.name);
          final bytes = utf8.encode(folderJson);   // Convert JSON string to bytes
          archive.addFile(ArchiveFile('Objects/Folders/${Utility.concatenateWithUnderscore(fixedFolderName)}.json', bytes.length, bytes));
          print('added Objects/Folders/${Utility.concatenateWithUnderscore(fixedFolderName)}.json to archive');
        }
      }

      // Check if there are any files to share
      if (archive.isEmpty) {
        throw Exception('Cannot share archive: No files to share');
      }

      // create an encoder instance
      final zipEncoder = ZipEncoder();

      // encode archive
      final encodedArchive = zipEncoder.encode(archive);

      // create temporary path to store zip file
      final String tempArchivePath = await FileService.tempFilePathGenerator('receiptcamp_archive_${Utility.generateUid().substring(0, 5)}.zip');

      // create a .zip file from the encoded bytes
      final File archiveFile = await File(tempArchivePath).writeAsBytes(encodedArchive!);

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
