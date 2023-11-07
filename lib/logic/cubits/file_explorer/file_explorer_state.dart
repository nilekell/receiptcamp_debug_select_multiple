part of 'file_explorer_cubit.dart';

sealed class FileExplorerCubitState extends Equatable {
  const FileExplorerCubitState();

  @override
  List<Object> get props => [];
}

final class FileExplorerCubitInitial extends FileExplorerCubitState {}

final class FileExplorerCubitLoading extends FileExplorerCubitState {}

final class FileExplorerCubitFolderInformationSuccess extends FileExplorerCubitState {
  const FileExplorerCubitFolderInformationSuccess({required this.folder});

  final Folder folder;

  @override
  List<Object> get props => [folder];
}

final class FileExplorerCubitError extends FileExplorerCubitState {}
