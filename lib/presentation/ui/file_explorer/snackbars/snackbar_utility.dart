import 'package:flutter/material.dart';
import 'package:receiptcamp/logic/cubits/file_system/file_system_cubit.dart';

abstract class SnackBarUtility {
  static String _message = '';

  static final SnackBar _appSnackBar = SnackBar(
    content: Text(_message),
    duration: const Duration(milliseconds: 2000),
  );

  static void showFileSystemSnackBar(BuildContext context, FileSystemCubitState state) {
    if (state is FileSystemCubitUploadSuccess) {
      _message = '${state.uploadedName} added successfully';
    } else if (state is FileSystemCubitUploadFailure) {
      _message = 'Failed to save file object';
    } else if (state is FileSystemCubitRenameSuccess) {
      _message = '${state.oldName} renamed to ${state.newName}';
    } else if (state is FileSystemCubitRenameFailure) {
      _message = 'Failed to rename ${state.oldName}';
    } else if (state is FileSystemCubitMoveSuccess) {
      _message = 'Moved ${state.oldName} to ${state.newName}';
    } else if (state is FileSystemCubitMoveFailure) {
      _message = 'Failed to move ${state.oldName} to ${state.newName}';
    } else if (state is FileSystemCubitDeleteSuccess) {
      _message = 'Deleted ${state.deletedName}';
    } else if (state is FileSystemCubitDeleteFailure) {
      _message = 'Failed to delete ${state.deletedName}';
    } else {
      print('showFileSystemSnackBar: state is ${state.runtimeType.toString()}');
      return;
    }
    
    print(_message);
    ScaffoldMessenger.of(context).showSnackBar(_appSnackBar);
  }
}

