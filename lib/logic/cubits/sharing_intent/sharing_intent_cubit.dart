// ignore_for_file: unused_local_variable

import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/models/folder.dart';
part 'sharing_intent_state.dart';


class SharingIntentCubit extends Cubit<SharingIntentState> {

  SharingIntentCubit({required this.mediaStream, required this.initialMedia}) : super(SharingIntentFilesRecieved());

  Stream<List<File>> mediaStream;
  Future<List<File>> initialMedia;

  List<File> files = <File>[];

  void init() async {
    print('SharingIntentCubit instantiated');
    mediaStream.listen((sharedFiles) {
      for (final f in sharedFiles) {
        files.add(f);
      }

      emit(SharingIntentFilesRecieved());
      print("Received shared files: $sharedFiles");
      return;
    }, onError:(error) {
      return;
    },);

    List<File> initialSharedFiles = await initialMedia;
    if (initialSharedFiles.isNotEmpty) {
      print("Initial shared files: $initialSharedFiles");
      files = initialSharedFiles;
      emit(SharingIntentFilesRecieved());
      return;
    }
  }

  void getFilesAndFolders() async {
    emit(SharingIntentLoading());
    try {
      final receiptFiles = files;
      final folders = await DatabaseRepository.instance.getFolders();
      emit(SharingIntentSuccess(folders: folders, files: receiptFiles));
    } on Exception catch (e) {
      print(e.toString());
      emit(SharingIntentError());
    }

  }

  void insertReceiptsIntoFolder(String folderId) {
    // maybe use isolate method
  }

}
