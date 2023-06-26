import 'package:flutter/material.dart';
import 'package:receiptcamp/logic/cubits/file_edit/file_editing_cubit.dart';

void showReceiptOptions(BuildContext context, FileEditingCubit fileEditingCubit) {
  showModalBottomSheet(
    context: context,
    builder: (bottomSheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Rename'),
          onTap: () {
            // show rename receipt dialog
          },
        ),
        ListTile(
          leading: const Icon(Icons.drive_file_move),
          title: const Text('Move'),
          onTap: () {
            // show move receipt dialog
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Delete'),
          onTap: () {
            // fileEditingCubit.deleteReceipt(receiptId);
          },
        ),
      ],
    ),
  );
}