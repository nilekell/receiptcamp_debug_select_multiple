import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';

part 'file_editing_cubit_state.dart';

class FileEditingCubit extends Cubit<FileEditingCubitState> {
  FileEditingCubit() : super(FileEditingCubitInitial());

  // Receipt methods

  renameReceipt(Receipt receipt, String newName) async {
    final oldName = receipt.name;
    try {
      await DatabaseRepository.instance.renameReceipt(receipt.id, newName);
      emit(FileEditingCubitRenameReceiptSuccess(oldName: oldName, newName: newName));
    } on Exception catch (e) {
      print(e.toString());
      emit(FileEditingCubitRenameReceiptFailure());
    }
  }

  moveReceipt(Receipt receipt, String targetFolderId) async {
    final oldFolder = await DatabaseRepository.instance.getFolderById(receipt.parentId);
    final newFolder = await DatabaseRepository.instance.getFolderById(targetFolderId);
    try {
      await DatabaseRepository.instance.moveReceipt(receipt, targetFolderId);
      emit(FileEditingCubitMoveReceiptSuccess(oldFolder: oldFolder.name, newFolder: newFolder.name));
    } on Exception catch (e) {
      print(e.toString());
      emit(FileEditingCubitMoveReceiptFailure());
    }
  }

  deleteReceipt(String receiptId) async {
    final receipt = await DatabaseRepository.instance.getReceiptById(receiptId);
    try {
      await DatabaseRepository.instance.deleteReceipt(receiptId);
      emit(FileEditingCubitDeleteReceiptSuccess(deletedReceiptName: receipt.name));
    } on Exception catch (e) {
      print(e.toString());
      emit(FileEditingCubitDeleteReceiptFailure());
    }
  }

  // Folder methods

  renameFolder(Folder folder, String newName) async {
    final oldName = folder.name;
    try {
      await DatabaseRepository.instance.renameFolder(folder.id, newName);
      emit(FileEditingCubitRenameFolderSuccess(oldName: oldName, newName: newName));
    } on Exception catch (e) {
      print(e.toString());
      emit(FileEditingCubitRenameFolderFailure());
    }
  }
  
  moveFolder(Folder folder, String targetFolderId) async {
    final oldFolder = folder.name;
    final targetFolder = await DatabaseRepository.instance.getFolderById(targetFolderId);
    final targetFolderName = targetFolder.name;
    try {
      await DatabaseRepository.instance.moveFolder(folder, targetFolderId);
      emit(FileEditingCubitMoveFolderSuccess(oldFolder: oldFolder, newFolder: targetFolderName));
    } on Exception catch (e) {
      print(e.toString());
      emit(FileEditingCubitMoveFolderFailure());
    }
  }

  deleteFolder(String folderId) async {
    final folder = await DatabaseRepository.instance.getFolderById(folderId);
    try {
      await DatabaseRepository.instance.deleteFolder(folderId);
      emit(FileEditingCubitDeleteFolderSuccess(deletedFolderName: folder.name));
    } on Exception catch (e) {
      print(e.toString());
      emit(FileEditingCubitDeleteFolderFailure());
    }
  }
}
