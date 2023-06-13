import 'package:flutter/material.dart';
import 'package:receiptcamp/logic/blocs/upload/upload_bloc.dart';
import 'package:receiptcamp/presentation/ui/file_navigator/create_folder_dialog.dart';

void showUploadOptions(BuildContext context, UploadBloc uploadBloc) {
  showModalBottomSheet(
          context: context,
          builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Choose from gallery'),
                    onTap: () {
                      uploadBloc.add(UploadTapEvent());
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera),
                    title: const Text('Take a photo'),
                    onTap: () {
                      uploadBloc.add(CameraTapEvent());
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.folder),
                    title: const Text('Create folder'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      showFolderDialog(context, uploadBloc);
                    },
                  ),
                ],
              ));
}