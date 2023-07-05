import 'package:flutter/material.dart';
import 'package:receiptcamp/logic/cubits/file_system/file_system_cubit.dart';

abstract interface class SnackBarUtility {
  static String _message = '';

  static final SnackBar _appSnackBar = SnackBar(
    content: Text(_message),
    duration: const Duration(milliseconds: 2000),
  );

  static void showFileEditSnackBar(BuildContext context, FileSystemCubitState state) {
    switch (state.runtimeType) {
      case FileSystemCubitUploadSuccess:
        FileSystemCubitUploadSuccess currentState = state as FileSystemCubitUploadSuccess;
        _message = '${currentState.uploadedName} added successfully';
        ScaffoldMessenger.of(context).showSnackBar(_appSnackBar);
        break;
      case FileSystemCubitUploadFailure:
        _message = 'Failed to save file object';
        ScaffoldMessenger.of(context).showSnackBar(_appSnackBar);
        break;
      case FileSystemCubitRenameSuccess:
        FileSystemCubitRenameSuccess currentState = state as FileSystemCubitRenameSuccess;
        _message = '${currentState.oldName} renamed to ${currentState.newName}';
        ScaffoldMessenger.of(context).showSnackBar(_appSnackBar);
        break;
      case FileSystemCubitRenameFailure:
        FileSystemCubitRenameFailure currentState = state as FileSystemCubitRenameFailure;
        _message = 'Failed to rename ${currentState.oldName}';
        ScaffoldMessenger.of(context).showSnackBar(_appSnackBar);
        break;
      case FileSystemCubitMoveSuccess:
        FileSystemCubitMoveSuccess currentState = state as FileSystemCubitMoveSuccess;
        _message = 'Moved ${currentState.oldName} to ${currentState.newName}';
        ScaffoldMessenger.of(context).showSnackBar(_appSnackBar);
        break;
      case FileSystemCubitMoveFailure:
        FileSystemCubitMoveFailure currentState = state as FileSystemCubitMoveFailure;
        _message = 'Failed to move ${currentState.oldName} to ${currentState.newName}';
        ScaffoldMessenger.of(context).showSnackBar(_appSnackBar);
        break;
      case FileSystemCubitDeleteSuccess:
        FileSystemCubitDeleteSuccess currentState = state as FileSystemCubitDeleteSuccess;
        _message = 'Deleted ${currentState.deletedName}';
        ScaffoldMessenger.of(context).showSnackBar(_appSnackBar);
        break;
      case FileSystemCubitDeleteFailure:
        FileSystemCubitDeleteFailure currentState = state as FileSystemCubitDeleteFailure;
        _message = 'Failed to delete ${currentState.deletedName}';
        ScaffoldMessenger.of(context).showSnackBar(_appSnackBar);
        break;
      default:
        print('state is ${state.runtimeType.toString()}');
        return;
    }
  }
}
