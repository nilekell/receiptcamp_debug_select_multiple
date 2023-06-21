import 'package:flutter/material.dart';
import 'package:receiptcamp/data/utils/folder_helper.dart';
import 'package:receiptcamp/logic/blocs/upload/upload_bloc.dart';

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
final TextEditingController _textEditingController = TextEditingController();

Future<void> showFolderDialog(
    BuildContext context) async {
  return await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _textEditingController,
                      validator: (value) {
                        if (FolderHelper.validFolderName(value!)) {
                          return 'Valid folder name';
                        } else {
                          return 'Invalid folder name';
                        }
                      },
                      decoration:
                          const InputDecoration(hintText: "Enter folder name"),
                    ),
                  ],
                )),
            title: const Text('New Folder'),
            actions: <Widget>[
              TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    // popping folder dialog context, then bottom sheet context
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }),
              TextButton(
                  child: const Text('Create'),
                  onPressed: () {
                    // popping folder dialog context, then bottom sheet context
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    UploadBloc().add(FolderCreateEvent(
                        name: _textEditingController.value.text));
                  }),
            ],
          );
        });
      });
}
