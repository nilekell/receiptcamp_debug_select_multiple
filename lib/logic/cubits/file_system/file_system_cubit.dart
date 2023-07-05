import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:share_plus/share_plus.dart';

part 'file_system_state.dart';

// responsible for all CRUD operations on files and folders (upload, delete, rename, move).
class FileSystemCubit extends Cubit<FileSystemCubitState> {
  FileSystemCubit() : super(FileSystemCubitInitial());

  // uploadReceipt
  // deleteReceipt
  // renameReceipt
  // moveReceipt

  // uploadFolder
  // deleteFolder
  // renameFolder
  // moveFolder
  



  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  // Receipt methods

  renameReceipt(Receipt receipt, String newName) async {
    final oldName = receipt.name;

    // Get extension from the old name
    final extension = oldName.split('.').last;

    // Append extension to the new name
    final newNameWithExtension = '$newName.$extension';

    try {
      await DatabaseRepository.instance.renameReceipt(receipt.id, newNameWithExtension);
      emit(FileSystemCubitRenameSuccess(oldName: oldName, newName: newNameWithExtension));
    } on Exception catch (e) {
      print(e.toString());
      emit(FileSystemCubitRenameFailure(oldName: oldName, newName: newNameWithExtension));
    }
  }

  moveReceipt(Receipt receipt, String targetFolderId) async {
    final newFolder = await DatabaseRepository.instance.getFolderById(targetFolderId);
    try {
      await DatabaseRepository.instance.moveReceipt(receipt, targetFolderId);
      emit(FileSystemCubitMoveSuccess(oldName: receipt.name, newName: newFolder.name));
    } on Exception catch (e) {
      print(e.toString());
      emit(FileSystemCubitMoveFailure(oldName: receipt.name, newName: newFolder.name));
    }
  }

  deleteReceipt(String receiptId) async {
    final receipt = await DatabaseRepository.instance.getReceiptById(receiptId);
    try {
      await DatabaseRepository.instance.deleteReceipt(receiptId);
      emit(FileSystemCubitDeleteSuccess(deletedName: receipt.name));
    } on Exception catch (e) {
      print(e.toString());
      emit(FileSystemCubitDeleteFailure(deletedName: receipt.name));
    }
  }

  // Folder methods

  renameFolder(Folder folder, String newName) async {
    final oldName = folder.name;
    try {
      await DatabaseRepository.instance.renameFolder(folder.id, newName);
      emit(FileSystemCubitRenameSuccess(oldName: oldName, newName: newName));
    } on Exception catch (e) {
      print(e.toString());
      emit(FileSystemCubitRenameFailure(oldName: oldName, newName: newName));
    }
  }
  
  moveFolder(Folder folder, String targetFolderId) async {
    final oldFolder = folder.name;
    final targetFolder = await DatabaseRepository.instance.getFolderById(targetFolderId);
    final targetFolderName = targetFolder.name;
    try {
      await DatabaseRepository.instance.moveFolder(folder, targetFolderId);
      emit(FileSystemCubitMoveSuccess(oldName: oldFolder, newName: targetFolderName));
    } on Exception catch (e) {
      print(e.toString());
      emit(FileSystemCubitMoveFailure(oldName: oldFolder, newName: targetFolderName));
    }
  }

  deleteFolder(String folderId) async {
    final folder = await DatabaseRepository.instance.getFolderById(folderId);
    try {
      await DatabaseRepository.instance.deleteFolder(folderId);
      emit(FileSystemCubitDeleteSuccess(deletedName: folder.name));
    } on Exception catch (e) {
      print(e.toString());
      emit(FileSystemCubitDeleteFailure(deletedName: folder.name));
    }
  }

  shareReceipt(Receipt receipt) async {
  try {
    // shows platform share sheet
    await Share.shareXFiles([XFile(receipt.localPath)], subject: receipt.name);
    emit(FileSystemCubitShareSuccess(receiptName: receipt.name));
  } on Exception catch (e) {
    print(e.toString());
    emit(FileSystemCubitShareFailure(receiptName: receipt.name));
  }
}

// Saving methods

saveImageToCameraRoll(Receipt receipt) async {
  try {
    await GallerySaver.saveImage(receipt.localPath);
    print('image saved to camera roll');
    emit(FileSystemCubitSaveImageSuccess(receiptName: receipt.name));
  } on Exception catch (e) {
    print(e.toString());
    emit(FileSystemCubitSaveImageFailure(receiptName: receipt.name));
  }
}

}
