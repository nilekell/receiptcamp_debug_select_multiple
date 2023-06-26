part of 'file_editing_cubit.dart';

sealed class FileEditingCubitState extends Equatable {
  const FileEditingCubitState();

  @override
  List<Object> get props => [];
}

final class FileEditingCubitInitial extends FileEditingCubitState {}

// Renaming States

final class FileEditingCubitRenameSuccess extends FileEditingCubitState {
  const FileEditingCubitRenameSuccess({required this.oldName, required this.newName});
  final String oldName;
  final String newName;

  @override
  List<Object> get props => [oldName, newName];
}

final class FileEditingCubitRenameFailure extends FileEditingCubitState {
  final String oldName;
  final String newName;

  const FileEditingCubitRenameFailure({required this.oldName, required this.newName});

  @override
  List<Object> get props => [oldName, newName];
}

// Moving states

final class FileEditingCubitMoveSuccess extends FileEditingCubitState {
  const FileEditingCubitMoveSuccess({required this.oldName, required this.newName});

  final String oldName;
  final String newName;

  @override
  List<Object> get props => [oldName, newName];
}

final class FileEditingCubitMoveFailure extends FileEditingCubitState {
  const FileEditingCubitMoveFailure({required this.oldName, required this.newName});

  final String oldName;
  final String newName;

  @override
  List<Object> get props => [oldName, newName];
}

// Deleting states

final class FileEditingCubitDeleteSuccess extends FileEditingCubitState {
  const FileEditingCubitDeleteSuccess({required this.deletedName});

  final String deletedName;

  @override
  List<Object> get props => [deletedName];
}

final class FileEditingCubitDeleteFailure extends FileEditingCubitState {
  const FileEditingCubitDeleteFailure({required this.deletedName});

  final String deletedName;

  @override
  List<Object> get props => [deletedName];
}
