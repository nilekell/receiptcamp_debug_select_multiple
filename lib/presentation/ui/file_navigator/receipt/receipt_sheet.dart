import 'package:flutter/material.dart';
import 'package:receiptcamp/logic/cubits/file_edit/file_editing_cubit.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/presentation/ui/file_navigator/receipt/delete_receipt_confirmation_dialog.dart';
import 'package:receiptcamp/presentation/ui/file_navigator/receipt/rename_receipt_dialog.dart';

void showReceiptOptions(BuildContext context, FileEditingCubit fileEditingCubit, Receipt receipt) {
  showModalBottomSheet(
    context: context,
    builder: (bottomSheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Rename'),
          onTap: () {
            // closing bottom sheet
            Navigator.of(bottomSheetContext).pop();
            // opening rename receipt dialog
            showRenameReceiptDialog(bottomSheetContext, fileEditingCubit, receipt);
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
            Navigator.of(bottomSheetContext).pop();
            // opening delete receipt dialog
            showDeleteReceiptDialog(bottomSheetContext, fileEditingCubit, receipt);
          },
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Download'),
          onTap: () {
            // Navigator.of(bottomSheetContext).pop();
            fileEditingCubit.saveImageToCameraRoll(receipt);
          },
        ),
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('Share'),
          onTap: () {
            // Navigator.of(bottomSheetContext).pop();
            fileEditingCubit.shareReceipt(receipt);
          },
        ),
      ],
    ),
  );
}