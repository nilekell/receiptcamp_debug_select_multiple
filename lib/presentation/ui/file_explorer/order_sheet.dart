import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

void showOrderOptions(BuildContext context, FolderViewCubit folderViewCubit, String currentOrder, String currentColumn, String folderId) {
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
      minChildSize: 0.25, // defines how low you can drag the the bottom sheet in relation to the screen height, until it close automatically
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
                  color: Colors.white),
            ),
          ),
          const Divider(
            thickness: 1,
            endIndent: 20,
            indent: 20,
            color: Colors.white,
          ),
          OrderListTile(
            title: 'Name',
            currentColumn: currentColumn,
            currentOrder: currentOrder,
            columnValue: 'name',
            folderViewCubit: folderViewCubit,
            folderId: folderId,
            bottomSheetContext: context,
          ),
          OrderListTile(
            title: 'Last modified',
            currentColumn: currentColumn,
            currentOrder: currentOrder,
            columnValue: 'lastModified',
            folderViewCubit: folderViewCubit,
            folderId: folderId,
            bottomSheetContext: context,
          ),
          OrderListTile(
            title: 'Storage used',
            currentColumn: currentColumn,
            currentOrder: currentOrder,
            columnValue: 'storageSize',
            folderViewCubit: folderViewCubit,
            folderId: folderId,
            bottomSheetContext: context,
          ),
        ],
      ),
    ),
      );
    },
  );
}

class OrderListTile extends StatelessWidget {
 final String title;
  final String currentColumn;
  final String currentOrder;
  final String columnValue;
  final FolderViewCubit folderViewCubit;
  final String folderId;
  final BuildContext bottomSheetContext;

  const OrderListTile({super.key, 
    required this.title,
    required this.currentColumn,
    required this.currentOrder,
    required this.columnValue,
    required this.folderViewCubit,
    required this.folderId,
    required this.bottomSheetContext,
  });

  final Color secondaryColour = Colors.white;
  final TextStyle textStyle = const TextStyle(fontSize: 16, color: Colors.white);
  final double arrowSize = 28;

  @override
  Widget build(BuildContext context) {
    // the padding and container are only rendered if the column is the same as the current column
    return Padding(
      padding: currentColumn == columnValue ? const EdgeInsets.only(right: 16.0) : EdgeInsets.zero,
      child: Container(
        decoration: currentColumn == columnValue ? const BoxDecoration(
          color: Color(primaryDarkBlue),
          borderRadius: BorderRadius.only(topRight: Radius.circular(25), bottomRight: Radius.circular(25),)
        ) : null,
        child: ListTile(
          // content padding moves list tile title to the left
          contentPadding: const EdgeInsets.symmetric(horizontal: 30.0),
          leading: currentColumn == columnValue && currentOrder == 'ASC'
                  ? Icon(Icons.arrow_upward, color: secondaryColour, size: arrowSize,)
                  : currentColumn == columnValue && currentOrder == 'DESC'
                      ? Icon(Icons.arrow_downward, color: secondaryColour, size: arrowSize,)
                      : Container(width: 20,),
          title: Text(
            title,
            style: TextStyle(fontSize: 16, color: secondaryColour),
          ),
          onTap: () {
            Navigator.of(bottomSheetContext).pop();
            folderViewCubit.fetchFilesInFolderSortedBy(folderId, column: columnValue, order: 'ASC', userSelectedSort: true);
          },
        ),
      ),
    );
  }
}
