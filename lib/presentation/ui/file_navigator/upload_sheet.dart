import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/presentation/ui/file_navigator/folder/create_folder_dialog.dart';

void showUploadOptions(BuildContext context, FolderViewCubit folderViewCubit, Folder currentFolder) {
  showModalBottomSheet(
    context: context,
    builder: (bottomSheetContext) {
      return BlocProvider.value(
        value: folderViewCubit,
        child: UploadOptionsBottomSheet(currentFolderId: currentFolder.id,),
      );
    },
  );
}

class UploadOptionsBottomSheet extends StatelessWidget {
  final String currentFolderId;

  const UploadOptionsBottomSheet({super.key, required this.currentFolderId});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.photo_library),
          title: const Text('Choose from gallery'),
          onTap: () {
            context.read<FolderViewCubit>().uploadReceipt(currentFolderId);
            // closing bottom sheet
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          leading: const Icon(Icons.camera),
          title: const Text('Take a photo'),
          onTap: () {
            context.read<FolderViewCubit>().uploadReceiptFromCamera(currentFolderId);
            // closing bottom sheet
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          leading: const Icon(Icons.folder),
          title: const Text('New folder'),
          onTap: () {
            // closing bottom sheet
            Navigator.of(context).pop();
            showCreateFolderDialog(context, context.read<FolderViewCubit>());
          },
        ),
      ],
    );
  }
}

