import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/presentation/ui/file_explorer/folder/create_folder_dialog.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

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
  final double iconSize = 45.0;
  final Color iconColour = Colors.white;
  final EdgeInsets paddingBetweenIcons = const EdgeInsets.all(10.0);

  const UploadOptionsBottomSheet({super.key, required this.currentFolder});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(primaryDarkBlue)), // background colour
      child: Row(
        // row of icons
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: paddingBetweenIcons,
            child: InkWell(
              child: Container(
                padding: const EdgeInsets.all(5),
                child: IconButton(
                    iconSize: iconSize,
                    onPressed: () {
                      context
                          .read<FolderViewCubit>()
                          .uploadReceiptFromGallery(currentFolder.id);
                      Navigator.of(context).pop();
                    },
                    icon: Image.asset(
                      'assets/images.png',
                      colorBlendMode: BlendMode.srcIn,
                      color: iconColour,
                    )),
              ),
            ),
          ),
          Padding(
            padding: paddingBetweenIcons,
            child: InkWell(
              child: Container(
                padding: const EdgeInsets.all(5),
                child: IconButton(
                    iconSize: iconSize,
                    color: iconColour,
                    onPressed: () {
                      context
                          .read<FolderViewCubit>()
                          .uploadReceiptFromCamera(currentFolder.id);
                      Navigator.of(context).pop();
                    },
                    icon: Image.asset(
                      'assets/camera.png',
                      colorBlendMode: BlendMode.srcIn,
                      color: iconColour,
                    )),
              ),
            ),
          ),
          Padding(
            padding: paddingBetweenIcons,
            child: InkWell(
              child: Container(
                padding: const EdgeInsets.all(5),
                child: IconButton(
                    iconSize: iconSize,
                    color: iconColour,
                    onPressed: () {
                      Navigator.of(context).pop();
                      showCreateFolderDialog(context,
                          context.read<FolderViewCubit>(), currentFolder);
                    },
                    icon: Image.asset(
                      'assets/folder_plus.png',
                      colorBlendMode: BlendMode.srcIn,
                      color: iconColour,
                    )),
              ),
            ),
          ),
          Padding(
            padding: paddingBetweenIcons,
            child: InkWell(
              child: Container(
                padding: const EdgeInsets.all(5),
                child: IconButton(
                    iconSize: iconSize,
                    color: iconColour,
                    onPressed: () {
                      Navigator.of(context).pop();
                      context
                          .read<FolderViewCubit>()
                          .uploadReceiptFromDocumentScan(currentFolder.id);
                    },
                    icon: Image.asset(
                      'assets/scan.png',
                      colorBlendMode: BlendMode.srcIn,
                      color: iconColour,
                    )),
              ),
            ),
          ),
          const SizedBox(
            height: 170,
          )
        ],
      ),
    );
  }
}
