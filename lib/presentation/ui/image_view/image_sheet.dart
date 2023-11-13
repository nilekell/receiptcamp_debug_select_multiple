import 'package:flutter/material.dart';
import 'package:receiptcamp/data/utils/file_helper.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

void showImageOptions(
    BuildContext context, Receipt receipt) {
  const Color secondaryColour = Colors.white;
  const TextStyle textStyle = TextStyle(fontSize: 16, color: secondaryColour);
  const double iconScale = 0.7;
  const double iconPadding = 8.0;

  showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: const Color(primaryDeepBlue),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topRight: Radius.circular(40.0)),
    ),
    context: context,
    builder: (bottomSheetContext) => DraggableScrollableSheet(
      initialChildSize: 0.35, // initial bottom sheet height
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
        ],
      ),
    ),
  );
}

