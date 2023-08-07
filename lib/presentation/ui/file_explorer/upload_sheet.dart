import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/presentation/ui/file_explorer/folder/create_folder_dialog.dart';

void showUploadOptions(BuildContext context, FolderViewCubit folderViewCubit,
    Folder currentFolder) {
  showModalBottomSheet(
    context: context,
    builder: (bottomSheetContext) {
      return BlocProvider.value(
        value: folderViewCubit,
        child: UploadOptionsBottomSheet(currentFolder: currentFolder),
      );
    },
  );
}

class UploadOptionsBottomSheet extends StatelessWidget {
  final Folder currentFolder;
  final double iconSize = 30.0;
  final Color iconColour = Colors.white;

  const UploadOptionsBottomSheet({super.key, required this.currentFolder});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Row background colour
      color: Colors.blue,
      child: Row(
        // row of icons
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Material(
              color: Colors.blue,
              child: InkWell(
                child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: IconButton(
                      color: iconColour,
                        iconSize: iconSize,
                        onPressed: () {
                          context
                              .read<FolderViewCubit>()
                              .uploadReceipt(currentFolder.id);
                          // closing bottom sheet
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.photo_library)),
                  ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Material(
              color: Colors.blue,
              child: InkWell(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: IconButton(
                      iconSize: iconSize,
                      color: iconColour,
                      onPressed: () {
                        context
                            .read<FolderViewCubit>()
                            .uploadReceiptFromCamera(currentFolder.id);
                        // closing bottom sheet
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.photo_camera)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Material(
              color: Colors.blue,
              child: InkWell(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: IconButton(
                      iconSize: iconSize,
                      color: iconColour,
                      onPressed: () {
                        // closing bottom sheet
                        Navigator.of(context).pop();
                        showCreateFolderDialog(context,
                            context.read<FolderViewCubit>(), currentFolder);
                      },
                      icon: const Icon(Icons.create_new_folder)),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 150,
          )
        ],
      ),
    );
  }
}