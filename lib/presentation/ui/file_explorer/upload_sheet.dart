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
  final EdgeInsets paddingBetweenIcons =
      const EdgeInsets.symmetric(horizontal: 25.0);
  final Color backgroundColour = const Color(primaryDarkBlue);

  const UploadOptionsBottomSheet({super.key, required this.currentFolder});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: backgroundColour), // background colour
      child: Row(
        // row of icon upload options
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: paddingBetweenIcons,
            child: UploadOption(
                currentFolderId: currentFolder.id,
                onPressed: () {
                  context
                      .read<FolderViewCubit>()
                      .uploadReceiptFromGallery(currentFolder.id);
                },
                assetPath: 'assets/images.png'),
          ),
          Padding(
            padding: paddingBetweenIcons,
            child: UploadOption(
                currentFolderId: currentFolder.id,
                onPressed: () {
                  context
                      .read<FolderViewCubit>()
                      .uploadReceiptFromCamera(currentFolder.id);
                },
                assetPath: 'assets/camera.png'),
          ),
          Padding(
            padding: paddingBetweenIcons,
            child: UploadOption(
                currentFolderId: currentFolder.id,
                onPressed: () {
                  showCreateFolderDialog(
                      context, context.read<FolderViewCubit>(), currentFolder);
                },
                assetPath: 'assets/folder_plus.png'),
          ),
          Padding(
            padding: paddingBetweenIcons,
            child: UploadOption(
                currentFolderId: currentFolder.id,
                onPressed: () {
                  context
                      .read<FolderViewCubit>()
                      .uploadReceiptFromDocumentScan(currentFolder.id);
                },
                assetPath: 'assets/scan.png'),
          ),
          const SizedBox(
            height: 170,
          )
        ],
      ),
    );
  }
}

class UploadOption extends StatelessWidget {
  const UploadOption({
    Key? key,
    required this.currentFolderId,
    required this.onPressed,
    required this.assetPath,
  }) : super(key: key);

  final String currentFolderId;
  final VoidCallback onPressed;
  final String assetPath;

  final double iconSize = 20.0;
  final Color iconColour = Colors.white;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: IconButton(
          iconSize: iconSize,
          color: iconColour,
          onPressed: () {
            onPressed;
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            assetPath,
            colorBlendMode: BlendMode.srcIn,
            color: iconColour,
          )),
    );
  }
}
