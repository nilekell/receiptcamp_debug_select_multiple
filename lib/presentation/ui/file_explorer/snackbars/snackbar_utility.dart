import 'package:flutter/material.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';

abstract class SnackBarUtility {
  static String _message = '';

  static final SnackBar _appSnackBar = SnackBar(
    content: Text(_message),
    duration: const Duration(milliseconds: 2000),
  );

  static void showSnackBar(BuildContext context, FolderViewState state) {
    if (state is FolderViewUploadSuccess) {
      _message = '${state.uploadedName} added successfully';
    } else if (state is FolderViewUploadFailure) {
      _message = 'Failed to save file object';
    } else if (state is FolderViewRenameSuccess) {
      _message = '${state.oldName} renamed to ${state.newName}';
    } else if (state is FolderViewRenameFailure) {
      _message = 'Failed to rename ${state.oldName}';
    } else if (state is FolderViewMoveSuccess) {
      _message = 'Moved ${state.oldName} to ${state.newName}';
    } else if (state is FolderViewMoveFailure) {
      _message = 'Failed to move ${state.oldName} to ${state.newName}';
    } else if (state is FolderViewDeleteSuccess) {
      _message = 'Deleted ${state.deletedName}';
    } else if (state is FolderViewDeleteFailure) {
      _message = 'Failed to delete ${state.deletedName}';
    } else {
      print('showFileSystemSnackBar: state is ${state.runtimeType.toString()}');
      return;
    }

    print(_message);
    ScaffoldMessenger.of(context).showSnackBar(_appSnackBar);
  }
}

