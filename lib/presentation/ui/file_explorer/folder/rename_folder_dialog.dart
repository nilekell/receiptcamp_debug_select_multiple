import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/utils/folder_helper.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

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
    textEditingController.text = widget.folder.name;
    textEditingController.addListener(_textChangeListener);
    // highlighting initial text after first frame is rendered so the Focus can be requested
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
      textEditingController.selection = TextSelection(
          baseOffset: 0, extentOffset: textEditingController.text.length);
    });

    super.initState();
  }

  void _textChangeListener() {
    bool isNameNotEmpty = textEditingController.text.isNotEmpty;
    bool isNameChanged = textEditingController.value.text.trim() != widget.folder.name;
    bool isNameValid = FolderHelper.validFolderName(textEditingController.text);

    setState(() {
      isEnabled = isNameNotEmpty && isNameChanged && isNameValid;
    });
  }

  final ButtonStyle textButtonStyle =
      TextButton.styleFrom(foregroundColor: Colors.white);

  final TextStyle actionButtonTextStyle = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40.0))),
      backgroundColor: const Color(primaryDarkBlue),
      content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                style: const TextStyle(color: Colors.white),
                  focusNode: _focusNode,
                  autofocus: true,
                  controller: textEditingController,
                  cursorColor: Colors.white,
                  decoration:
                      const InputDecoration(hintText: "Enter new Folder name", hintStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white), // <-- Set color for normal state
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white), // <-- Set color for focused state
              ),),
                  inputFormatters: [
                    // Regex disallows special characters like ., /, \, $, etc.
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[^./\\$?*|:"><]*'))
                  ]),
            ],
          )),
      title: const Text(
        'Rename Folder',
        textAlign: TextAlign.left,
        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)
      ),
      actions: <Widget>[
        TextButton(
          style: textButtonStyle,
            child: Text('Cancel', style: actionButtonTextStyle),
            onPressed: () {
              // closing dialog
              Navigator.of(context).pop();
            }),
        TextButton(
          style: textButtonStyle,
          onPressed: isEnabled
              ? () {
                  context.read<FolderViewCubit>().renameFolder(
                      widget.folder, textEditingController.value.text);
                  // closing folder dialog
                  Navigator.of(context).pop();
                }
              // only enabling button when isEnabled is true
              : null,
          child: Text('Rename', style: actionButtonTextStyle),
        ),
      ],
    );
  }

  @override
  void dispose() {
    textEditingController.removeListener(_textChangeListener);
    textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
