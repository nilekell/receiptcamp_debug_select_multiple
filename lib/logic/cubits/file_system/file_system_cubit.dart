import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/data/utils/receipt_helper.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/models/tag.dart';

part 'file_system_state.dart';

// responsible for all CRUD operations on files and folders (upload, delete, rename, move).
class FileSystemCubit extends Cubit<FileSystemCubitState> {
  FileSystemCubit() : super(FileSystemCubitInitial());

  // method to display root folder contents when the bottom navigation tab switches to file explorer
  initializeFileSystemCubit() async {
    emit(FileSystemCubitInitial());
    fetchFolderInformation('a1');
  }

  fetchFolderInformation(String folderId) async {
    emit(FileSystemCubitLoading());
    try {
      final folder = await DatabaseRepository.instance.getFolderById(folderId);
      emit(FileSystemCubitFolderInformationSuccess(folder: folder));
    } catch (error) {
      emit(FileSystemCubitError());
    }
  }

  fetchFiles(String folderId) async {
    emit(FileSystemCubitLoading());
    try {
      final folder = await DatabaseRepository.instance.getFolderById(folderId);
      final List<Object> files = await DatabaseRepository.instance.getFolderContents(folderId);
      emit(FileSystemCubitLoadedSuccess(files: files, folder: folder));
    } catch (error) {
      emit(FileSystemCubitError());
    }
  }

  // method for when folder tile is tapped
  selectFolder(String folderId) async {
    emit(FileSystemCubitLoading());
    try {
      final folder = await DatabaseRepository.instance.getFolderById(folderId);
      final List<Object> files = await DatabaseRepository.instance.getFolderContents(folderId);
      emit(FileSystemCubitLoadedSuccess(files: files, folder: folder));
    } catch (error) {
      emit(FileSystemCubitError());
    }
  }

  // method for when back button is tapped
  navigateBack(String parentFolderId) async {
    emit(FileSystemCubitLoading());
    try {
      final Folder parentFolder = await DatabaseRepository.instance.getFolderById(parentFolderId);
      final List<Object> files = await DatabaseRepository.instance.getFolderContents(parentFolderId);
      if (files.isNotEmpty) {
        emit(FileSystemCubitLoadedSuccess(files: files, folder: parentFolder));
      } else {
        emit(FileSystemCubitEmptyFiles());
      }
    } catch (error) {
      emit(FileSystemCubitError());
    }
  }

  // return new list of folder items whenever a folder item is deleted/moved/created
  // consider emitting another state for above actions e.g. FileSystemCubitFolderItemsChangedState

  uploadReceipt(String currentFolderId) async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final XFile? receiptImage =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if (receiptImage == null) {
        return;
      }

      final List<dynamic> results = await ReceiptService.processingReceiptAndTags(receiptImage);
      final Receipt receipt = results[0];
      final List<Tag> tags = results[1];

      await DatabaseRepository.instance.insertTags(tags);
      await DatabaseRepository.instance.insertReceipt(receipt);
      print('Image ${receipt.name} saved at ${receipt.localPath}');

      final folder = await DatabaseRepository.instance.getFolderById(currentFolderId);
      final currentFolderContents = await DatabaseRepository.instance.getFolderContents(receipt.parentId);
      emit(FileSystemCubitUploadSuccess(uploadedName: receipt.name));
      emit(FileSystemCubitFolderItemsChangedState(files: currentFolderContents, folder: folder));
    } on PlatformException catch (e) {
      print(e.toString());
      emit(FileSystemCubitUploadFailure());
    } on Exception catch (e) {
      print('Error in uploadReceipt: $e');
      emit(FileSystemCubitUploadFailure());
      return;
    }
  }

  uploadReceiptFromCamera(String currentFolderId) async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final XFile? receiptPicture =
          await imagePicker.pickImage(source: ImageSource.camera);
      if (receiptPicture == null) {
        return;
      }

      final List<dynamic> results = await ReceiptService.processingReceiptAndTags(receiptPicture);
      final Receipt receipt = results[0];
      final List<Tag> tags = results[1];

      await DatabaseRepository.instance.insertTags(tags);
      await DatabaseRepository.instance.insertReceipt(receipt);
      print('Image ${receipt.name} saved at ${receipt.localPath}');

      final folder = await DatabaseRepository.instance.getFolderById(receipt.parentId);
      final currentFolderContents = await DatabaseRepository.instance.getFolderContents(receipt.parentId);
      emit(FileSystemCubitFolderItemsChangedState(files: currentFolderContents, folder: folder));

      emit(FileSystemCubitUploadSuccess(uploadedName: receipt.name));
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

      final currentFolderContents = await DatabaseRepository.instance.getFolderContents(folder.parentId);

      emit(FileSystemCubitUploadSuccess(uploadedName: folder.name));
      emit(FileSystemCubitFolderItemsChangedState(files: currentFolderContents, folder: folder));
    } on Exception catch (e) {
      print('Error in uploadFolder: $e');
      emit(FileSystemCubitUploadFailure());
    }
  }

  // Remainder of your new methods as requested.
  deleteReceipt(String receiptId) async {
    final receipt = await DatabaseRepository.instance.getReceiptById(receiptId);
    final folder = await DatabaseRepository.instance.getFolderById(receipt.parentId);
    try {
      await DatabaseRepository.instance.deleteReceipt(receiptId);
      final files = await DatabaseRepository.instance.getFolderContents(receipt.parentId);
      emit(FileSystemCubitFolderItemsChangedState(files: files, folder: folder));
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
      final folder = await DatabaseRepository.instance.getFolderById(receipt.parentId);
      final currentFolderContents = await DatabaseRepository.instance.getFolderContents(receipt.parentId);
      emit(FileSystemCubitMoveSuccess(oldName: receipt.name, newName: targetFolderId));
      emit(FileSystemCubitFolderItemsChangedState(files: currentFolderContents, folder: folder));
    } on Exception catch (e) {
      print(e.toString());
      emit(FileSystemCubitMoveFailure(oldName: receipt.name, newName: targetFolderId));
    }
  }

  deleteFolder(String folderId) async {
    final String deletedFolderName = (await DatabaseRepository.instance.getFolderById(folderId)).name;
    final Folder deletedFolderParent = await DatabaseRepository.instance.getFolderById(folderId);
  
    try {
      await DatabaseRepository.instance.deleteFolder(folderId);
      final deletedFolderParentFiles = await DatabaseRepository.instance.getFolderContents(deletedFolderParent.id);
      emit(FileSystemCubitDeleteSuccess(deletedName: deletedFolderName));
      emit(FileSystemCubitFolderItemsChangedState(files: deletedFolderParentFiles, folder: deletedFolderParent));
    } on Exception catch (e) {
      print(e.toString());
      emit(FileSystemCubitDeleteFailure(deletedName: deletedFolderName));
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
    final String targetFolderName = (await DatabaseRepository.instance.getFolderById(folder.id)).name;
    final currentFolderContents = await DatabaseRepository.instance.getFolderContents(folder.parentId);

    try {
      await DatabaseRepository.instance.moveFolder(folder, targetFolderId);
      emit(FileSystemCubitMoveSuccess(oldName: folder.name, newName: targetFolderName));
      emit(FileSystemCubitFolderItemsChangedState(files: currentFolderContents, folder: folder));
    } on Exception catch (e) {
      print(e.toString());
      emit(FileSystemCubitMoveFailure(oldName: folder.name, newName: targetFolderName));
    }
  }

  refreshFiles(String folderId) async {
    try {
      final Folder thisFolder = await DatabaseRepository.instance.getFolderById(folderId);
      final files = await DatabaseRepository.instance.getFolderContents(folderId);
      emit(FileSystemCubitFolderItemsChangedState(files: files, folder: thisFolder));
    } on Exception catch (e) {
      print(e.toString());
      emit(FileSystemCubitRefreshFailureState());
    }
  }
}
