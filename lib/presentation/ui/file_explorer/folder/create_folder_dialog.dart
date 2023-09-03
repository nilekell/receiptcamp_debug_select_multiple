import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/utils/folder_helper.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/models/folder.dart';

Future<void> showCreateFolderDialog(
    BuildContext context, FolderViewCubit folderViewCubit, Folder currentFolder) async {
  return await showDialog(
      context: context,
      builder: (createFolderDialogContext) {
        return BlocProvider.value(
          value: folderViewCubit,
          child: FolderDialog(currentFolder: currentFolder),
        );
      });
}

class FolderDialog extends StatefulWidget {
  final Folder currentFolder;

  const FolderDialog({super.key, required this.currentFolder});

  @override
  State<FolderDialog> createState() => _FolderDialogState();
}

class _FolderDialogState extends State<FolderDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController textEditingController = TextEditingController();
  bool isEnabled = false;

  @override
  void initState() {
    context.read<FolderViewCubit>();
    isEnabled = textEditingController.text.isNotEmpty;
    textEditingController.addListener(_textPresenceListener);
    textEditingController.addListener(_validFolderNameListener);
    super.initState();
  }

  void _textPresenceListener() {
    if (isEnabled != textEditingController.text.isNotEmpty) {
      setState(() {
        // disabling/enabling create button when text is empty/present
        isEnabled = textEditingController.text.isNotEmpty;
      });
    }
  }

  void _validFolderNameListener() async {
    bool isNameValid = FolderHelper.validFolderName(textEditingController.text);
    if (isEnabled != isNameValid) {
      setState(() {
        // disabling/enabling create button when text is a valid/invalid folder name
        isEnabled = isNameValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: textEditingController,
                decoration:
                    const InputDecoration(hintText: "Enter folder name"),
              ),
            ],
          )),
      title: const Text('New Folder', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w500)),
      actions: <Widget>[
        TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              // closing folder dialog
              Navigator.of(context).pop();
            }),
        TextButton(
          onPressed: isEnabled
              ? () {
                print('saving ${textEditingController.value.text} in ${widget.currentFolder.name}');
                  context.read<FolderViewCubit>().uploadFolder(textEditingController.value.text, widget.currentFolder.id);
                  // closing folder dialog
                  Navigator.of(context).pop();
                }
              // only enabling button when isEnabled is true
              : null,
          child: const Text('Create'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    textEditingController.removeListener(_textPresenceListener);
    textEditingController.removeListener(_validFolderNameListener);
    textEditingController.dispose();
    super.dispose();
  }
}
