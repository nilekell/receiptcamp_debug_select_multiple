import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/utils/folder_helper.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

Future<void> showCreateFolderDialog(BuildContext context,
    FolderViewCubit folderViewCubit, Folder currentFolder) async {
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
    textEditingController.addListener(_textChangeListener);
    super.initState();
  }

  void _textChangeListener() async {
    bool isNotEmpty = textEditingController.text.isNotEmpty;
    bool isNameValid = FolderHelper.validFolderName(textEditingController.text);

    if (isEnabled != (isNotEmpty && isNameValid)) {
      setState(() {
        isEnabled = isNotEmpty && isNameValid;
      });
    }
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
                autofocus: true,
                controller: textEditingController,
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: "Enter folder name",
                  hintStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.white), // <-- Set color for normal state
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.white), // <-- Set color for focused state
                  ),
                ),
              ),
            ],
          )),
      title: const Text('New Folder',
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
      actions: <Widget>[
        TextButton(
            style: textButtonStyle,
            child: Text('Cancel', style: actionButtonTextStyle),
            onPressed: () {
              // closing folder dialog
              Navigator.of(context).pop();
            }),
        TextButton(
          style: textButtonStyle,
          onPressed: isEnabled
              ? () {
                  print(
                      'saving ${textEditingController.value.text} in ${widget.currentFolder.name}');
                  context.read<FolderViewCubit>().uploadFolder(
                      textEditingController.value.text,
                      widget.currentFolder.id);
                  Navigator.of(context).pop();
                }
              // only enabling button when isEnabled is true
              : null,
          child: Text('Create', style: actionButtonTextStyle),
        ),
      ],
    );
  }

  @override
  void dispose() {
    textEditingController.removeListener(_textChangeListener);
    textEditingController.dispose();
    super.dispose();
  }
}
