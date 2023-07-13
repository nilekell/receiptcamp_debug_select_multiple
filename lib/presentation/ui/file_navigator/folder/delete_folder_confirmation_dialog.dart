import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/models/folder.dart';

Future<void> showDeleteFolderDialog(BuildContext context,
    FolderViewCubit folderViewCubit, Folder folder) async {
  return await showDialog(
    context: context,
    builder: (deleteFolderDialogContext) {
      return BlocProvider.value(
        value: folderViewCubit,
        child: DeleteFolderDialog(folder: folder,),
      );
    },
  );
}

class DeleteFolderDialog extends StatelessWidget {
  final Folder folder;

  const DeleteFolderDialog({
    super.key, required this.folder
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Forever'),
      content: Text('${folder.name} will be deleted forever.'),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Delete'),
          onPressed: () {
            context.read<FolderViewCubit>().deleteFolder(folder.id);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

