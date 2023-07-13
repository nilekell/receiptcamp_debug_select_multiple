part of 'file_system_cubit.dart';

sealed class FileSystemCubitState extends Equatable {
  const FileSystemCubitState();

  @override
  List<Object> get props => [];
}

final class FileSystemCubitActionState extends FileSystemCubitState {
  final String folderId;

  const FileSystemCubitActionState({required this.folderId});
}

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

final class FileSystemCubitError extends FileSystemCubitState {}

// Renaming States

final class FileSystemCubitRenameSuccess extends FileSystemCubitActionState {
  const FileSystemCubitRenameSuccess({required this.oldName, required this.newName, required super.folderId});
  final String oldName;
  final String newName;

  @override
  List<Object> get props => [oldName, newName];
}

final class FileSystemCubitRenameFailure extends FileSystemCubitActionState {
  final String oldName;
  final String newName;

  const FileSystemCubitRenameFailure({required this.oldName, required this.newName, required super.folderId});

  @override
  List<Object> get props => [oldName, newName];
}

// Moving states

final class FileSystemCubitMoveSuccess extends FileSystemCubitActionState {
  const FileSystemCubitMoveSuccess({required this.oldName, required this.newName, required super.folderId});

  final String oldName;
  final String newName;

  @override
  List<Object> get props => [oldName, newName];
}

final class FileSystemCubitMoveFailure extends FileSystemCubitActionState {
  const FileSystemCubitMoveFailure({required this.oldName, required this.newName, required super.folderId});

  final String oldName;
  final String newName;

  @override
  List<Object> get props => [oldName, newName];
}

// Deleting states

final class FileSystemCubitDeleteSuccess extends FileSystemCubitActionState {
  const FileSystemCubitDeleteSuccess({required this.deletedName, required super.folderId});

  final String deletedName;

  @override
  List<Object> get props => [deletedName];
}

final class FileSystemCubitDeleteFailure extends FileSystemCubitActionState {
  const FileSystemCubitDeleteFailure({required this.deletedName, required super.folderId});

  final String deletedName;

  @override
  List<Object> get props => [deletedName];
}

// Sharing states

final class FileSystemCubitShareSuccess extends FileSystemCubitActionState {
  const FileSystemCubitShareSuccess({required this.receiptName, required super.folderId});

  final String receiptName;

  @override
  List<Object> get props => [receiptName];
}

final class FileSystemCubitShareFailure extends FileSystemCubitActionState {
  const FileSystemCubitShareFailure({required this.receiptName, required super.folderId});

  final String receiptName;

  @override
  List<Object> get props => [receiptName];
}

final class FileSystemCubitUploadSuccess extends FileSystemCubitActionState {
  final String uploadedName;

  const FileSystemCubitUploadSuccess({required this.uploadedName, required super.folderId});

  @override
  List<Object> get props => [uploadedName];
}

final class FileSystemCubitUploadFailure extends FileSystemCubitActionState {
  const FileSystemCubitUploadFailure({required super.folderId});
}

final class FileSystemCubitRefreshSuccessState extends FileSystemCubitActionState {
  final List<Object> files;

  const FileSystemCubitRefreshSuccessState({required super.folderId, required this.files});

  @override
  List<Object> get props => [files];
}

final class FileSystemCubitRefreshFailureState extends FileSystemCubitActionState {
  const FileSystemCubitRefreshFailureState({required super.folderId});
}
