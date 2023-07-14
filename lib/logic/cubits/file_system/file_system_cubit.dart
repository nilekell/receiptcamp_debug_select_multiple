import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/models/folder.dart';

part 'file_system_state.dart';

// responsible for displaying folder name, back button, and upload button with correct folder reference
class FileSystemCubit extends Cubit<FileSystemCubitState> {
  FileSystemCubit() : super(FileSystemCubitInitial());

  // method to display root folder information when the bottom navigation tab switches to file explorer
  initializeFileSystemCubit() async {
    emit(FileSystemCubitInitial());
    fetchFolderInformation('a1');
  }

  // method to fetch displayed folder information, which is required for FolderName, BackButton, FolderView, UploadButton
  fetchFolderInformation(String folderId) async {
    emit(FileSystemCubitLoading());
    try {
      final folder = await DatabaseRepository.instance.getFolderById(folderId);
      emit(FileSystemCubitFolderInformationSuccess(folder: folder));
    } catch (error) {
      emit(FileSystemCubitError());
    }
  }

  // method for when folder tile is tapped
  selectFolder(String folderId) async {
    emit(FileSystemCubitLoading());
    try {
      final folder = await DatabaseRepository.instance.getFolderById(folderId);
      emit(FileSystemCubitFolderInformationSuccess(folder: folder));
    } catch (error) {
      emit(FileSystemCubitError());
    }
  }

  // method for when back button is tapped
  navigateBack(String parentFolderId) async {
    emit(FileSystemCubitLoading());
    try {
      final Folder parentFolder = await DatabaseRepository.instance.getFolderById(parentFolderId);
      emit(FileSystemCubitFolderInformationSuccess(folder: parentFolder));
    } catch (error) {
      emit(FileSystemCubitError());
    }
  }
}
