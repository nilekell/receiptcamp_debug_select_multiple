// ignore_for_file: unused_local_variable

import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/data/utils/receipt_helper.dart';
import 'package:receiptcamp/logic/blocs/home/home_bloc.dart';
import 'package:receiptcamp/logic/cubits/file_explorer/file_explorer_cubit.dart';
import 'package:receiptcamp/logic/cubits/landing/landing_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/models/tag.dart';
import 'package:share_plus/share_plus.dart';
part 'sharing_intent_state.dart';


class SharingIntentCubit extends Cubit<SharingIntentState> {

  SharingIntentCubit({required this.homeBloc, required this.fileExplorerCubit, required this.mediaStream, required this.initialMedia, required this.landingCubit}) : super(SharingIntentFilesInitial());

  final HomeBloc homeBloc;
  final FileExplorerCubit fileExplorerCubit;
  final LandingCubit landingCubit;

  Stream<List<File>> mediaStream;
  Future<List<File>> initialMedia;

  void init() async {
    emit(SharingIntentFilesInitial());
    try {
      // print('SharingIntentCubit instantiated');

      List<File> files = <File>[];

      mediaStream.listen(
        (sharedFiles) {
          for (final f in sharedFiles) {
            files.add(f);
          }

          emit(SharingIntentFilesRecieved(files: files));

          if (sharedFiles.isEmpty) {
            emit(SharingIntentNoValidFiles());
            return;
          }

          // print("Received shared stream files: $sharedFiles");
          getFolders();
          return;
        },
        onError: (error) {
          print(error.toString());
          emit(SharingIntentError());
          files.clear();
          return;
        },
      );

      List<File> initialSharedFiles = await initialMedia;
      if (initialSharedFiles.isNotEmpty) {
        // print("Received shared initial files: $initialSharedFiles");
        files = initialSharedFiles;
        emit(SharingIntentFilesRecieved(files: files));
        getFolders();
        return;
      }
    } on Exception catch (e) {
      print(e.toString());
      emit(SharingIntentError());
    }
  }

  void getFolders() async {
    emit(SharingIntentLoading());
    try {
      final folders = await DatabaseRepository.instance.getFolders();
      emit(SharingIntentSuccess(folders: folders));
    } on Exception catch (e) {
      print(e.toString());
      emit(SharingIntentError());
    }
  }

  void insertReceiptsIntoFolder(String folderId, List<File> receiptFiles) async {
    emit(const SharingIntentSavingReceipts(folders: []));

    List<Receipt> savedReceipts = [];

    try{
      // iterating over images and uploading them as receipts consecutively
      // REFACTOR TO PROCESS IN BACKGROUND USING ISOLATE depending on number of files
      for (final file in receiptFiles) {
        final XFile receiptDocument = XFile(file.path);
        final List<dynamic> results =
            await ReceiptService.processingReceiptAndTags(
                receiptDocument, folderId);
        final Receipt receipt = results[0];
        final List<Tag> tags = results[1];

        await DatabaseRepository.instance.insertTags(tags);
        await DatabaseRepository.instance.insertReceipt(receipt);

        savedReceipts.add(receipt);
      }

      // notifying home bloc to reload after all receipts imported
      homeBloc.add(HomeLoadReceiptsEvent());
      // directly navigating to FileExplorer tab
      landingCubit.updateIndex(1);
      // navigating to parent folder in FileExplorer when RecieveReceiptView is closed
      // notifying fileExplorerCubit to reload after all receipts imported
      fileExplorerCubit.selectFolder(folderId);
      emit(SharingIntentClose(folders: const [], savedReceipts: savedReceipts));
    } on Exception catch (e) {
      print(e.toString());
      emit(SharingIntentError());
    }
  }

}
