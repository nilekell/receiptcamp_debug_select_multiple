import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

Future<void> showDeleteFolderDialog(BuildContext context,
    FolderViewCubit folderViewCubit, Folder folder) async {
  return await showDialog(
    context: context,
    builder: (deleteFolderDialogContext) {
      return BlocProvider.value(
        value: folderViewCubit,
        child: DeleteFolderDialog(
          folder: folder,
        ),
      );
    },
  );
}

class DeleteFolderDialog extends StatelessWidget {
  final Folder folder;

  DeleteFolderDialog({super.key, required this.folder});

  final ButtonStyle textButtonStyle =
      TextButton.styleFrom(foregroundColor: Colors.white);

  final TextStyle actionButtonTextStyle = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40.0))),
      backgroundColor: const Color(primaryDarkBlue),
      title: const Text(
        'Delete forever?',
        textAlign: TextAlign.left,
        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      ),
      content: Text(
        "'${folder.name}' and its contents will be deleted forever.",
        style: const TextStyle(color: Colors.white),
      ),
      actions: <Widget>[
        TextButton(
          style: textButtonStyle,
          child: Text('Cancel', style: actionButtonTextStyle),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          style: textButtonStyle,
          child: Text('Delete', style: actionButtonTextStyle),
          onPressed: () {
            context.read<FolderViewCubit>().deleteFolder(folder.id);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
