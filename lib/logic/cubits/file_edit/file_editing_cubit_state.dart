part of 'file_editing_cubit_cubit.dart';

sealed class FileEditingCubitState extends Equatable {
  const FileEditingCubitState();

  @override
  List<Object> get props => [];
}

final class FileEditingCubitInitial extends FileEditingCubitState {}

// Renaming States

final class FileEditingCubitRenameReceiptSuccess extends FileEditingCubitState {
  const FileEditingCubitRenameReceiptSuccess({required this.oldName, required this.newName});
  
  final String oldName;
  final String newName;

  @override
  List<Object> get props => [oldName, newName];
}

final class FileEditingCubitRenameFolderSuccess extends FileEditingCubitState {
  const FileEditingCubitRenameFolderSuccess({required this.oldName, required this.newName});
  final String oldName;
  final String newName;

  @override
  List<Object> get props => [oldName, newName];
}

final class FileEditingCubitRenameReceiptFailure extends FileEditingCubitState {}

final class FileEditingCubitRenameFolderFailure extends FileEditingCubitState {}

// Moving states

final class FileEditingCubitMoveReceiptSuccess extends FileEditingCubitState {
  const FileEditingCubitMoveReceiptSuccess({required this.oldFolder, required this.newFolder});

  final String oldFolder;
  final String newFolder;

  @override
  List<Object> get props => [oldFolder, newFolder];
}

final class FileEditingCubitMoveFolderSuccess extends FileEditingCubitState {
  const FileEditingCubitMoveFolderSuccess({required this.oldFolder, required this.newFolder});

  final String oldFolder;
  final String newFolder;

  @override
  List<Object> get props => [oldFolder, newFolder];
}

final class FileEditingCubitMoveReceiptFailure extends FileEditingCubitState {}

final class FileEditingCubitMoveFolderFailure extends FileEditingCubitState {}

// Deleting states

final class FileEditingCubitDeleteReceiptSuccess extends FileEditingCubitState {
  const FileEditingCubitDeleteReceiptSuccess({required this.deletedReceiptName});

  final String deletedReceiptName;

  @override
  List<Object> get props => [deletedReceiptName];
}

final class FileEditingCubitDeleteFolderSuccess extends FileEditingCubitState {
  const FileEditingCubitDeleteFolderSuccess({required this.deletedFolderName});

  final String deletedFolderName;

  @override
  List<Object> get props => [deletedFolderName]; 
}

final class FileEditingCubitDeleteReceiptFailure extends FileEditingCubitState {}

final class FileEditingCubitDeleteFolderFailure extends FileEditingCubitState {}
