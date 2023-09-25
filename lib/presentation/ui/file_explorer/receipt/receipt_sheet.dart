import 'package:flutter/material.dart';
import 'package:receiptcamp/data/utils/file_helper.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/presentation/ui/file_explorer/receipt/delete_receipt_confirmation_dialog.dart';
import 'package:receiptcamp/presentation/ui/file_explorer/receipt/move_receipt_dialog.dart';
import 'package:receiptcamp/presentation/ui/file_explorer/receipt/rename_receipt_dialog.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

void showReceiptOptions(
    BuildContext context, FolderViewCubit folderViewCubit, Receipt receipt) {
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
              scale: 0.8,
              child: Image.asset(
                'assets/receipt.png',
                color: secondaryColour,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
            title: Text(
              receipt.name.split('.').first,
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
              // opening rename receipt dialog
              showRenameReceiptDialog(
                  bottomSheetContext, folderViewCubit, receipt);
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
              Navigator.of(bottomSheetContext).pop();
              // show move receipt dialog
              showMoveReceiptDialog(context, folderViewCubit, receipt);
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
              // opening delete receipt dialog
              showDeleteReceiptDialog(
                  bottomSheetContext, folderViewCubit, receipt);
            },
          ),
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(left: iconPadding),
              child: Transform.scale(
                  scale: iconScale,
                  child: Image.asset(
                    'assets/download.png',
                    color: secondaryColour,
                    colorBlendMode: BlendMode.srcIn,
                  )),
            ),
            title: const Text(
              'Download',
              style: textStyle,
            ),
            onTap: () {
              Navigator.of(bottomSheetContext).pop();
              FileService.saveImageToCameraRoll(receipt);
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
              FileService.shareReceipt(receipt);
            },
          ),
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(left: iconPadding),
              child: Transform.translate(
                offset: const Offset(-8, 0),
                child: Transform.scale(
                    scale: 0.75,
                    child: Image.asset(
                      'assets/export_as_pdf.png',
                      color: secondaryColour,
                      colorBlendMode: BlendMode.srcIn,
                    )),
              ),
            ),
            title: Transform.translate(
              offset: const Offset(-15, 0),
              child: const Text(
                'Export as PDF',
                style: textStyle,
              ),
            ),
            onTap: () {
              Navigator.of(bottomSheetContext).pop();
              FileService.shareReceiptAsPdf(receipt);
            },
          ),
          const SizedBox(height: 50)
        ],
      ),
    ),
  );
}
