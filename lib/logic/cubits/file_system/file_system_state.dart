part of 'file_system_cubit.dart';

sealed class FileSystemCubitState extends Equatable {
  const FileSystemCubitState();

  @override
  List<Object> get props => [];
}

final class FileSystemCubitInitial extends FileSystemCubitState {}

// Renaming States

final class FileSystemCubitRenameSuccess extends FileSystemCubitState {
  const FileSystemCubitRenameSuccess({required this.oldName, required this.newName});
  final String oldName;
  final String newName;

  @override
  List<Object> get props => [oldName, newName];
}

final class FileSystemCubitRenameFailure extends FileSystemCubitState {
  final String oldName;
  final String newName;

  const FileSystemCubitRenameFailure({required this.oldName, required this.newName});

  @override
  List<Object> get props => [oldName, newName];
}

// Moving states

final class FileSystemCubitMoveSuccess extends FileSystemCubitState {
  const FileSystemCubitMoveSuccess({required this.oldName, required this.newName});

  final String oldName;
  final String newName;

  @override
  List<Object> get props => [oldName, newName];
}

final class FileSystemCubitMoveFailure extends FileSystemCubitState {
  const FileSystemCubitMoveFailure({required this.oldName, required this.newName});

  final String oldName;
  final String newName;

  @override
  List<Object> get props => [oldName, newName];
}

// Deleting states

final class FileSystemCubitDeleteSuccess extends FileSystemCubitState {
  const FileSystemCubitDeleteSuccess({required this.deletedName});

  final String deletedName;

  @override
  List<Object> get props => [deletedName];
}

final class FileSystemCubitDeleteFailure extends FileSystemCubitState {
  const FileSystemCubitDeleteFailure({required this.deletedName});

  final String deletedName;

  @override
  List<Object> get props => [deletedName];
}

// Sharing states

final class FileSystemCubitShareSuccess extends FileSystemCubitState {
  const FileSystemCubitShareSuccess({required this.receiptName});

  final String receiptName;

  @override
  List<Object> get props => [receiptName];
}

final class FileSystemCubitShareFailure extends FileSystemCubitState {
  const FileSystemCubitShareFailure({required this.receiptName});

  final String receiptName;

  @override
  List<Object> get props => [receiptName];
}

// Saving states

final class FileSystemCubitSaveImageSuccess extends FileSystemCubitState {
  const FileSystemCubitSaveImageSuccess({required this.receiptName});

  final String receiptName;

  @override
  List<Object> get props => [receiptName];
}

final class FileSystemCubitSaveImageFailure extends FileSystemCubitState {
  const FileSystemCubitSaveImageFailure({required this.receiptName});

  final String receiptName;

  @override
  List<Object> get props => [receiptName];
}
