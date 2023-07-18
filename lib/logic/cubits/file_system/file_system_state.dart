part of 'file_system_cubit.dart';

sealed class FileSystemCubitState extends Equatable {
  const FileSystemCubitState();

  @override
  List<Object> get props => [];
}

final class FileSystemCubitInitial extends FileSystemCubitState {}

final class FileSystemCubitLoading extends FileSystemCubitState {}

final class FileSystemCubitFolderInformationSuccess extends FileSystemCubitState {
  const FileSystemCubitFolderInformationSuccess({required this.folder});

  final Folder folder;

  @override
  List<Object> get props => [folder];
}

final class FileSystemCubitError extends FileSystemCubitState {}
