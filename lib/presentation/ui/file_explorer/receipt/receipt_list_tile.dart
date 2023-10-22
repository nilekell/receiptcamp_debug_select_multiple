import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/presentation/screens/image_view.dart';
import 'package:receiptcamp/presentation/screens/select_multiple_screen.dart';
import 'package:receiptcamp/presentation/ui/file_explorer/receipt/receipt_sheet.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';


class ReceiptListTile extends StatelessWidget {
  final Receipt receipt;
  final String displayName;
  final String displayDate;
  final String displaySize;
  final String price;
  final bool withSize;
  // Optional withSize parameter used to determine whether to show displaySize in subtitle & ReceiptListTileVisual
  final String draggableName;

  ReceiptListTile({Key? key, required this.receipt, this.withSize = false, this.price = ''})
      // displayName is the file name without the file extension and is cut off when the receipt name
      // is > 25 chars or would require 2 lines to be shown completely
      : displayName = receipt.name.length > 25
            ? "${receipt.name.substring(0, 25)}..."
            : receipt.name.split('.').first,
        draggableName = receipt.name.length > 10
            ? "${receipt.name.substring(0, 10)}..."
            : receipt.name,
        displayDate = Utility.formatDisplayDateFromDateTime(
            Utility.formatDateTimeFromUnixTimestamp(receipt.lastModified)),
        displaySize = Utility.bytesToSizeString(receipt.storageSize),
          
        super(key: key);

  final TextStyle displayNameStyle = const TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, color: Color(primaryGrey));
  final TextStyle displayDateStyle =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

  @override
  Widget build(BuildContext context) {
    return Draggable<Receipt>(
      dragAnchorStrategy: (draggable, context, position) {
        return const Offset(50, 50);
      },
      data: receipt,
      childWhenDragging: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(0.3),
          BlendMode.srcIn,
        ),
        child: price == '' ? ReceiptListTileVisual(receipt: receipt, withSize: withSize) : ReceiptListTileVisual(receipt: receipt, price: (receipt as ReceiptWithPrice).priceString,),
      ),
      feedback: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Opacity(
              opacity: 0.7,
              child: SizedBox(
                height: 100,
                width: 100,
                child: ClipRRect(
                  // square image corners
                  borderRadius: const BorderRadius.all(Radius.zero),
                  child: Image.file(
                    File(receipt.localPath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, 10),
              child: Text(
                draggableName,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: GestureDetector(
            onLongPress: () {
              Navigator.of(context).push(
                    SlidingSelectMultipleTransitionRoute(
                        item: receipt));
            },
            child: ListTile(
                leading: SizedBox(
                  height: 50,
                  width: 50,
                  child: ClipRRect(
                    // square image corners
                    borderRadius: const BorderRadius.all(Radius.zero),
                    child: Image.file(
                      File(receipt.localPath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                subtitle: Text(
                  withSize
                    ? displaySize
                    : price != '' ? price : 'Modified $displayDate',
                  style: displayDateStyle,
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Color(primaryGrey),
                    size: 30,
                  ),
                  onPressed: () {
                    showReceiptOptions(
                        context, context.read<FolderViewCubit>(), receipt);
                  },
                ),
                onTap: () {
                  Navigator.of(context)
                      .push(SlidingImageTransitionRoute(receipt: receipt));
                },
                title: Text(displayName,
                    style: displayNameStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis)),
          )),
    );
  }
}

// placeholder widget while draggable is active
class ReceiptListTileVisual extends StatelessWidget {
  final Receipt receipt;
  final String displayName;
  final String displayDate;
  final String displaySize;
  final String price;
  final bool withSize;

  ReceiptListTileVisual({Key? key, required this.receipt,  this.withSize = false, this.price = ''})
      // displayName is the file name without the file extension and is cut off when the receipt name
      // is > 25 chars or would require 2 lines to be shown completely
      : displayName = receipt.name.length > 25
            ? "${receipt.name.substring(0, 25)}...".split('.').first
            : receipt.name.split('.').first,
        displayDate = Utility.formatDisplayDateFromDateTime(
            Utility.formatDateTimeFromUnixTimestamp(receipt.lastModified)),
        displaySize = Utility.bytesToSizeString(receipt.storageSize),
        super(key: key);

  final TextStyle displayNameStyle = const TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, color: Color(primaryGrey));
  
  final TextStyle subTextStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: ListTile(
            leading: SizedBox(
              height: 50,
              width: 50,
              child: ClipRRect(
                // square image corners
                borderRadius: const BorderRadius.all(Radius.zero),
                child: Image.file(
                  File(receipt.localPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            subtitle: Text(
              withSize
                  ? displaySize
                  : price != '' ? price : 'Modified $displayDate', // Ternary operator to decide text
              style: subTextStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: Color(primaryGrey),
                size: 30,
              ),
              onPressed: () {
                return;
              },
            ),
            onTap: () {
              return;
            },
            title: Text(displayName,
                style: displayNameStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis)));
  }
}