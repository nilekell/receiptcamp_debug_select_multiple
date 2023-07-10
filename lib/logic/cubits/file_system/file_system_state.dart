part of 'file_system_cubit.dart';

sealed class FileSystemCubitState extends Equatable {
  const FileSystemCubitState();

  @override
  List<Object> get props => [];
}

final class FileSystemCubitActionState extends FileSystemCubitState {}

final class FileSystemCubitInitial extends FileSystemCubitState {}

final class FileSystemCubitLoading extends FileSystemCubitState {}

final class FileSystemCubitFolderInformationSuccess extends FileSystemCubitState {
  const FileSystemCubitFolderInformationSuccess({required this.folder});

  final Folder folder;

  @override
  List<Object> get props => [folder];
}

final class FileSystemCubitLoadedSuccess extends FileSystemCubitState {
  final List<dynamic> files;
  final Folder folder;

  const FileSystemCubitLoadedSuccess({required this.files, required this.folder});
}

final class FileSystemCubitFolderItemsChangedState extends FileSystemCubitActionState {
  final List<dynamic> files;
  final Folder folder;

  FileSystemCubitFolderItemsChangedState({required this.files, required this.folder});



  @override
  List<Object> get props => [files];
}

final class FileSystemCubitEmptyFiles extends FileSystemCubitState {}

final class FileSystemCubitError extends FileSystemCubitState {}

// Renaming States

final class FileSystemCubitRenameSuccess extends FileSystemCubitActionState {
  FileSystemCubitRenameSuccess({required this.oldName, required this.newName});
  final String oldName;
  final String newName;

  @override
  List<Object> get props => [oldName, newName];
}

final class FileSystemCubitRenameFailure extends FileSystemCubitActionState {
  final String oldName;
  final String newName;

  FileSystemCubitRenameFailure({required this.oldName, required this.newName});

  @override
  List<Object> get props => [oldName, newName];
}

// Moving states

final class FileSystemCubitMoveSuccess extends FileSystemCubitActionState {
  FileSystemCubitMoveSuccess({required this.oldName, required this.newName});

  final String oldName;
  final String newName;

  @override
  List<Object> get props => [oldName, newName];
}

final class FileSystemCubitMoveFailure extends FileSystemCubitActionState {
  FileSystemCubitMoveFailure({required this.oldName, required this.newName});

  final String oldName;
  final String newName;

  @override
  List<Object> get props => [oldName, newName];
}

// Deleting states

final class FileSystemCubitDeleteSuccess extends FileSystemCubitActionState {
  FileSystemCubitDeleteSuccess({required this.deletedName});

  final String deletedName;

  @override
  List<Object> get props => [deletedName];
}

final class FileSystemCubitDeleteFailure extends FileSystemCubitActionState {
  FileSystemCubitDeleteFailure({required this.deletedName});

  final String deletedName;

  @override
  List<Object> get props => [deletedName];
}

// Sharing states

final class FileSystemCubitShareSuccess extends FileSystemCubitActionState {
  FileSystemCubitShareSuccess({required this.receiptName});

  final String receiptName;

  @override
  List<Object> get props => [receiptName];
}

final class FileSystemCubitShareFailure extends FileSystemCubitActionState {
  FileSystemCubitShareFailure({required this.receiptName});

  final String receiptName;

  @override
  List<Object> get props => [receiptName];
}

final class FileSystemCubitUploadSuccess extends FileSystemCubitActionState {
  final String uploadedName;

  FileSystemCubitUploadSuccess({required this.uploadedName});

  @override
  List<Object> get props => [uploadedName];
}

final class FileSystemCubitUploadFailure extends FileSystemCubitActionState {}

final class FileSystemCubitRefreshSuccessState extends FileSystemCubitActionState {
  final List<Object> files;

  FileSystemCubitRefreshSuccessState(this.files);

  @override
  List<Object> get props => [files];
}

final class FileSystemCubitRefreshFailureState extends FileSystemCubitActionState {}
