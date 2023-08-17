import "package:flutter/material.dart";
import "package:receiptcamp/data/utils/receipt_helper.dart";
import "package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart";

// utility class that creates and shows snackbars displayed on file explorer screen
abstract class SnackBarUtility {
  static void showSnackBar(BuildContext context, FolderViewState state) {
    String message = "";

    switch (state) {
      case FolderViewUploadSuccess():
        message = "'${state.uploadedName}' added successfully";
        break;
      case FolderViewUploadFailure():
        switch (state.validationType) {
          case ValidationError.size:
            message = 'Image(s) too large to upload';
            break;
          case ValidationError.text:
            message = "Image(s) not recognised as receipt(s)";
            break;
          case ValidationError.both:
            message = 'Image(s) too large and not recognised as receipt(s)';
            break;
          case ValidationError.none:
            break;
        }
        break;
      case FolderViewRenameSuccess():
        message = "'${state.oldName}' renamed to '${state.newName}'";
        break;
      case FolderViewRenameFailure():
        message = "Failed to rename '${state.oldName}'";
        break;
      case FolderViewMoveSuccess():
        message = "Moved '${state.oldName}' to '${state.newName}'";
        break;
      case FolderViewMoveFailure():
        message = "Failed to move '${state.oldName}' to '${state.newName}'";
        break;
      case FolderViewDeleteSuccess():
        message = "Deleted '${state.deletedName}'";
        break;
      case FolderViewDeleteFailure():
        message = "Failed to delete '${state.deletedName}'";
        break;
      default:
        print('Unknown state in showSnackBar: ${state.runtimeType}');
        return;
    }

    final SnackBar appSnackBar = SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 2000),
    );

    ScaffoldMessenger.of(context).showSnackBar(appSnackBar);
  }
}


