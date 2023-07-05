import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/data/utils/receipt_helper.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';

part 'file_system_state.dart';

// responsible for all CRUD operations on files and folders (upload, delete, rename, move).
class FileSystemCubit extends Cubit<FileSystemCubitState> {
  FileSystemCubit() : super(FileSystemCubitInitial());

  uploadReceipt() async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final XFile? receiptImage =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if (receiptImage == null) {
        return;
      }

      final results = await ReceiptService.processingReceiptAndTags(receiptImage);
      final receipt = results[0];
      final tags = results[1];

      await DatabaseRepository.instance.insertTags(tags);
      await DatabaseRepository.instance.insertReceipt(receipt);
      print('Image ${receipt.name} saved at ${receipt.localPath}');

      emit(FileSystemCubitUploadSuccess(receipt.name));
    } on PlatformException catch (e) {
      print(e.toString());
      emit(FileSystemCubitUploadFailure());
    } on Exception catch (e) {
      print('Error in uploadReceipt: $e');
      emit(FileSystemCubitUploadFailure());
      return;
    }
  }

  uploadReceiptFromCamera() async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final XFile? receiptPicture =
          await imagePicker.pickImage(source: ImageSource.camera);
      if (receiptPicture == null) {
        return;
      }

      final results = await ReceiptService.processingReceiptAndTags(receiptPicture);
      final receipt = results[0];
      final tags = results[1];

      await DatabaseRepository.instance.insertTags(tags);
      await DatabaseRepository.instance.insertReceipt(receipt);
      print('Image ${receipt.name} saved at ${receipt.localPath}');

      emit(FileSystemCubitUploadSuccess(receipt.name));
    } on PlatformException catch (e) {
      print(e.toString());
      emit(FileSystemCubitUploadFailure());
    } on Exception catch (e) {
      print('Error in uploadReceiptFromCamera: $e');
      emit(FileSystemCubitUploadFailure());
      return;
    }
  }

  uploadFolder(String folderName, String parentFolderId) async {
    try {
      // creating folder id
      final folderId = Utility.generateUid();
      final currentTime = Utility.getCurrentTime();

      // create folder object
      final folder = Folder(id: folderId, name: folderName, lastModified: currentTime, parentId: parentFolderId );

      // save folder
      DatabaseRepository.instance.insertFolder(folder);
      print('Folder ${folder.name} saved in ${folder.parentId}');
      emit(FileSystemCubitUploadSuccess(folder.name));
    } on Exception catch (e) {
      print('Error in uploadFolder: $e');
      emit(FileSystemCubitUploadFailure());
    }
  }

  // Remainder of your new methods as requested.
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

  renameReceipt(Receipt receipt, String newName) async {
    final oldName = receipt.name;
    try {
      await DatabaseRepository.instance.renameReceipt(receipt.id, newName);
      emit(FileSystemCubitRenameSuccess(oldName: oldName, newName: newName));
    } on Exception catch (e) {
      print(e.toString());
      emit(FileSystemCubitRenameFailure(oldName: oldName, newName: newName));
    }
  }

  moveReceipt(Receipt receipt, String targetFolderId) async {
    try {
      await DatabaseRepository.instance.moveReceipt(receipt, targetFolderId);
      emit(FileSystemCubitMoveSuccess(oldName: receipt.name, newName: targetFolderId));
    } on Exception catch (e) {
      print(e.toString());
      emit(FileSystemCubitMoveFailure(oldName: receipt.name, newName: targetFolderId));
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
    try {
      await DatabaseRepository.instance.moveFolder(folder, targetFolderId);
      emit(FileSystemCubitMoveSuccess(oldName: folder.name, newName: targetFolderId));
    } on Exception catch (e) {
      print(e.toString());
      emit(FileSystemCubitMoveFailure(oldName: folder.name, newName: targetFolderId));
    }
  }
}
