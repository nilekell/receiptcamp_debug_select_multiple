import 'package:flutter/material.dart';
import 'package:receiptcamp/data/utils/folder_helper.dart';
import 'package:receiptcamp/logic/blocs/upload/upload_bloc.dart';

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
final TextEditingController _textEditingController = TextEditingController();

Future<void> showFolderDialog(BuildContext context, UploadBloc uploadBloc) async {
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
                    Navigator.of(context).pop();
                  }),
              TextButton(
                  child: const Text('Create'),
                  onPressed: () {
                    print(_textEditingController.value.text);
                    uploadBloc.add(FolderCreateEvent(name: _textEditingController.value.text));
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
      });
}
