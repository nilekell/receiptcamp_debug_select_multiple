part of 'folder_view_cubit.dart';

sealed class FolderViewState extends Equatable {
  const FolderViewState();

  @override
  List<Object> get props => [];
}

final class FolderViewActionState extends FolderViewState {
  final String folderId;

  const FolderViewActionState({required this.folderId});
  
}

final class FolderViewInitial extends FolderViewState {}

final class FolderViewLoading extends FolderViewState {}

final class FolderViewLoadedSuccess extends FolderViewState {
  final List<dynamic> files;
  final Folder folder;
  final String orderedBy;
  final String order;
  const FolderViewLoadedSuccess({required this.files, required this.folder, required this.orderedBy, required this.order});

  @override
  List<Object> get props => [files, folder, orderedBy, order];
}

final class FolderViewError extends FolderViewState {}

// Renaming States

final class FolderViewRenameSuccess extends FolderViewActionState {
  const FolderViewRenameSuccess({required this.oldName, required this.newName, required super.folderId});
  final String oldName;
  final String newName;

  @override
  List<Object> get props => [oldName, newName];
}

final class FolderViewRenameFailure extends FolderViewActionState {
  final String oldName;
  final String newName;

  const FolderViewRenameFailure({required this.oldName, required this.newName, required super.folderId});

  @override
  List<Object> get props => [oldName, newName];
}

// Moving states

final class FolderViewMoveSuccess extends FolderViewActionState {
  const FolderViewMoveSuccess({required this.oldName, required this.newName, required super.folderId});

  final String oldName;
  final String newName;

  @override
  List<Object> get props => [oldName, newName];
}

final class FolderViewMoveFailure extends FolderViewActionState {
  const FolderViewMoveFailure({required this.oldName, required this.newName, required super.folderId});

  final String oldName;
  final String newName;

  @override
  List<Object> get props => [oldName, newName];
}

// Deleting states

final class FolderViewDeleteSuccess extends FolderViewActionState {
  const FolderViewDeleteSuccess({required this.deletedName, required super.folderId});

  final String deletedName;

  @override
  List<Object> get props => [deletedName];
}

final class FolderViewDeleteFailure extends FolderViewActionState {
  const FolderViewDeleteFailure({required this.deletedName, required super.folderId});

  final String deletedName;

  @override
  List<Object> get props => [deletedName];
}

// Sharing states

final class FolderViewShareSuccess extends FolderViewActionState {
  const FolderViewShareSuccess({required this.receiptName, required super.folderId});

  final String receiptName;

  @override
  List<Object> get props => [receiptName];
}

final class FolderViewShareFailure extends FolderViewActionState {
  final String errorMessage;
  final String folderName;

  const FolderViewShareFailure({required super.folderId, required this.errorMessage, required this.folderName});

  @override
  List<Object> get props => [errorMessage];
}

final class FolderViewUploadSuccess extends FolderViewActionState {
  final String uploadedName;

  const FolderViewUploadSuccess({required this.uploadedName, required super.folderId});

  @override
  List<Object> get props => [uploadedName];
}

final class FolderViewUploadFailure extends FolderViewActionState {
  final ValidationError validationType;

  const FolderViewUploadFailure({required super.folderId, required this.validationType});
}

final class FolderViewPermissionsFailure extends FolderViewActionState {
  final PermissionFailedResult permissionResult;

  const FolderViewPermissionsFailure({required super.folderId, required this.permissionResult});
}