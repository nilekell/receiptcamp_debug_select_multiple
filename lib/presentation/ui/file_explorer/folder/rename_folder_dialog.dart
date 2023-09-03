import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/utils/folder_helper.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/models/folder.dart';

Future<void> showRenameFolderDialog(BuildContext context,
    FolderViewCubit folderViewCubit, Folder folder) async {
  return await showDialog(
      context: context,
      builder: (renameFolderDialogContext) {
        return BlocProvider.value(
          value: folderViewCubit,
          child: RenameFolderDialog(folder: folder),
        );
      });
}

class RenameFolderDialog extends StatefulWidget {
  final Folder folder;

  const RenameFolderDialog({super.key, required this.folder});

  @override
  State<RenameFolderDialog> createState() => _RenameFolderDialogState();
}

class _RenameFolderDialogState extends State<RenameFolderDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isEnabled = false;

  @override
  void initState() {
    context.read<FolderViewCubit>();
    // setting initial text shown in form to name of folder
    String nameWithoutExtension = widget.folder.name;
    textEditingController.text = nameWithoutExtension;
    textEditingController.addListener(_textPresenceListener);
    textEditingController.addListener(_validFolderNameListener);
    // highlighting initial text after first frame is rendered so the Focus can be requested
    WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(_focusNode);
          textEditingController.selection = TextSelection(
              baseOffset: 0, extentOffset: textEditingController.text.length);
        });

    super.initState();
  }

  void _textPresenceListener() {
      setState(() {
        // disabling create button when text is empty & text value != folder's current name
        isEnabled = textEditingController.text.isNotEmpty &&
            textEditingController.value.text != widget.folder.name;
      });
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
                focusNode: _focusNode,
                  autofocus: true,
                  controller: textEditingController,
                  decoration:
                      const InputDecoration(hintText: "Enter new Folder name"),
                  // This ensures that any input that doesn't match the filename format is ignored.
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[^.]*'))
                  ]),
            ],
          )),
      title: const Text('Rename Folder', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w500),),
      actions: <Widget>[
        TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              // closing dialog
              Navigator.of(context).pop();
            }),
        TextButton(
          onPressed: isEnabled
              ? () {
                  context.read<FolderViewCubit>().renameFolder(
                      widget.folder, textEditingController.value.text);
                  // closing folder dialog
                  Navigator.of(context).pop();
                }
              // only enabling button when isEnabled is true
              : null,
          child: const Text('Rename'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    textEditingController.removeListener(_textPresenceListener);
    textEditingController.removeListener(_validFolderNameListener);
    textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
