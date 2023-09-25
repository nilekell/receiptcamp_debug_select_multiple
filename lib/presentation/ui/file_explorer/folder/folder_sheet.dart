import 'package:flutter/material.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/presentation/ui/file_explorer/folder/delete_folder_confirmation_dialog.dart';
import 'package:receiptcamp/presentation/ui/file_explorer/folder/move_folder_dialog.dart';
import 'package:receiptcamp/presentation/ui/file_explorer/folder/rename_folder_dialog.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

void showFolderOptions(
    BuildContext context, FolderViewCubit folderViewCubit, Folder folder) {
  const Color secondaryColour = Colors.white;
  const TextStyle textStyle = TextStyle(fontSize: 16, color: secondaryColour);
  const double iconScale = 0.7;
  const double iconPadding = 8.0;

  showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: const Color(primaryDeepBlue),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    context: context,
    builder: (bottomSheetContext) => DraggableScrollableSheet(
      initialChildSize: 0.5, // initial bottom sheet height
      minChildSize: 0.25, // minimum possible bottom sheet height
      maxChildSize:
          0.8, // defines how high you can drag the the bottom sheet in relation to the screen height
      expand: false,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        children: [
          const SizedBox(
            height: 5,
          ),
          ListTile(
            leading: Transform.scale(
              scale: 0.9,
              child: Image.asset(
                'assets/folder.png',
                color: secondaryColour,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
            title: Text(
              folder.name,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: secondaryColour),
            ),
          ),
          const Divider(
            thickness: 1,
            endIndent: 20,
            indent: 20,
            color: secondaryColour,
          ),
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(left: iconPadding),
              child: Transform.scale(
                scale: iconScale,
                child: Image.asset(
                  'assets/pencil.png',
                  color: secondaryColour,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
            title: const Text(
              'Rename',
              style: textStyle,
            ),
            onTap: () {
              // closing bottom sheet
              Navigator.of(bottomSheetContext).pop();
              // opening rename folder dialog
              showRenameFolderDialog(bottomSheetContext, folderViewCubit, folder);
            },
          ),
          ListTile(
            leading: Padding(
                padding: const EdgeInsets.only(left: iconPadding),
                child: Transform.scale(
                  scale: 0.8,
                  child: Image.asset(
                    'assets/folder_move.png',
                    color: secondaryColour,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                )),
            title: const Text(
              'Move',
              style: textStyle,
            ),
            onTap: () {
              // closing bottom sheet
              Navigator.of(bottomSheetContext).pop();
              // show move folder dialog
              showMoveFolderDialog(bottomSheetContext, folderViewCubit, folder);
            },
          ),
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(left: iconPadding),
              child: Transform.scale(
                  scale: iconScale,
                  child: Image.asset(
                    'assets/bin.png',
                    color: secondaryColour,
                    colorBlendMode: BlendMode.srcIn,
                  )),
            ),
            title: const Text(
              'Delete',
              style: textStyle,
            ),
            onTap: () {
              Navigator.of(bottomSheetContext).pop();
              // opening deleting folder dialog
              showDeleteFolderDialog(bottomSheetContext, folderViewCubit, folder);
            },
          ),
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(left: iconPadding),
              child: Transform.scale(
                  scale: iconScale,
                  child: Image.asset(
                    'assets/share.png',
                    color: secondaryColour,
                    colorBlendMode: BlendMode.srcIn,
                  )),
            ),
            title: const Text(
              'Share',
              style: textStyle,
            ),
            onTap: () {
              Navigator.of(bottomSheetContext).pop();
              // opening deleting folder dialog
              folderViewCubit.shareFolder(folder);
            },
          ),
          const SizedBox(height: 50)
        ],
      ),
    ),
  );
}
