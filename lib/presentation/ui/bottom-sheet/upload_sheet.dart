import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/blocs/upload/upload_bloc.dart';
import 'package:receiptcamp/presentation/ui/file_navigator/create_folder_dialog.dart';

void showUploadOptions(BuildContext context) {
  showModalBottomSheet(
      context: context,
      builder: (context) => BlocProvider(
                create: (BuildContext context) => UploadBloc()..add(UploadInitialEvent()),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    UploadBloc().add(UploadTapEvent());
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera),
                  title: const Text('Take a photo'),
                  onTap: () {
                    UploadBloc().add(CameraTapEvent());
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.folder),
                  title: const Text('Create folder'),
                  onTap: () async {
                    showFolderDialog(context);
                  },
                ),
              ],
            ),
          ));
}
