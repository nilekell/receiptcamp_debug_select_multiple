import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

void showOrderOptions(BuildContext context, FolderViewCubit folderViewCubit, String currentOrder, String currentColumn, String folderId) {
  const Color secondaryColour = Colors.white;
  const TextStyle textStyle = TextStyle(fontSize: 16, color: secondaryColour);
  const double arrowSize = 28;

  showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: const Color(primaryDeepBlue),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topRight: Radius.circular(40.0)),
    ),
    context: context,
    builder: (bottomSheetContext) {
      return BlocProvider.value(
        value: folderViewCubit,
        child: DraggableScrollableSheet(
      initialChildSize: 0.5, // initial bottom sheet height
      minChildSize: 0.25, // minimum possible bottom sheet height
      maxChildSize:
          0.8, // defines how high you can drag the the bottom sheet in relation to the screen height
      expand: false,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        children: [
          const SizedBox(
            height: 15,
          ),
          const ListTile(
            title: Text(
              'Sort by',
              style: TextStyle(
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 30.0),
            leading: currentColumn == 'name' && currentOrder == 'ASC'
                    ? const Icon(Icons.arrow_upward, color: secondaryColour, size: arrowSize,)
                    : currentColumn == 'name' && currentOrder == 'DESC'
                        ? const Icon(Icons.arrow_downward, color: secondaryColour, size: arrowSize,)
                        : Container(width: 20,),
            title: const Text(
              'Name',
              style: textStyle,
            ),
            onTap: () {
              Navigator.of(bottomSheetContext).pop();
              folderViewCubit.fetchFilesInFolderSortedBy(folderId, column: 'name', order: 'ASC', userSelectedSort: true);
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 30.0),
            leading: currentColumn == 'lastModified' && currentOrder == 'ASC'
                    ? const Icon(Icons.arrow_upward, color: secondaryColour, size: arrowSize,)
                    : currentColumn == 'lastModified' && currentOrder == 'DESC'
                        ? const Icon(Icons.arrow_downward, color: secondaryColour, size: arrowSize,)
                        : Container(width: 20,),
            title: const Text(
              'Last modified',
              style: textStyle,
            ),
            onTap: () {
              Navigator.of(bottomSheetContext).pop();
              folderViewCubit.fetchFilesInFolderSortedBy(folderId, column: 'lastModified', order: 'ASC', userSelectedSort: true);
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 30.0),
            leading: currentColumn == 'storageSize' && currentOrder == 'ASC'
                    ? const Icon(Icons.arrow_upward, color: secondaryColour, size: arrowSize,)
                    : currentColumn == 'storageSize' && currentOrder == 'DESC'
                        ? const Icon(Icons.arrow_downward, color: secondaryColour, size: arrowSize,)
                        : Container(width: 20,),
            title: const Text(
              'Storage used',
              style: textStyle,
            ),
            onTap: () {
              Navigator.of(bottomSheetContext).pop();
              folderViewCubit.fetchFilesInFolderSortedBy(folderId, column: 'storageSize', order: 'ASC', userSelectedSort: true);
            },
          ),
          const SizedBox(height: 50)
        ],
      ),
    ),
      );
    },
  );
}
