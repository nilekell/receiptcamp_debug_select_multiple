import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';
import 'package:in_app_review/in_app_review.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  final TextStyle tileTextStyle = const TextStyle(color: Colors.white, fontSize: 18);
  final double tileIconSize = 38;
  final Color tileIconColour = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(primaryLightBlue),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const SizedBox(height: 100),
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
            child: Row(
              children: <Widget>[
                Text(
                  'Receipt',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Medium weight
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
                Text(
                  'Camp',
                  style: TextStyle(
                    fontWeight: FontWeight.normal, // Regular weight
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.feedback_outlined,
            size: tileIconSize, color: tileIconColour),
            title: Text(
              'Feedback',
              style: tileTextStyle,
            ),
            onTap: () async {
              final InAppReview inAppReview = InAppReview.instance;
              if (await inAppReview.isAvailable()) {
                inAppReview.openStoreListing(appStoreId: appStoreId);
              }
            },
          ),
          // commenting out for future usage, currently unnecessary
          /*ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => {Navigator.of(context).pop()},
          ),*/
          // temporary buttons for debugging
          kDebugMode
              ? ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete all receipts'),
                  onTap: () {
                    DatabaseRepository.instance.deleteAll();
                  },
                )
              : Container(),
          kDebugMode
              ? ListTile(
                  leading: const Icon(Icons.print),
                  title: const Text('Print all receipts'),
                  onTap: () {
                    DatabaseRepository.instance.printAllReceipts();
                  },
                )
              : Container(),
          kDebugMode
              ? ListTile(
                  leading: const Icon(Icons.print),
                  title: const Text('Print all tags'),
                  onTap: () {
                    DatabaseRepository.instance.printAllTags();
                  },
                )
              : Container(),
          kDebugMode
              ? ListTile(
                  leading: const Icon(Icons.print),
                  title: const Text('Print all folders'),
                  onTap: () {
                    DatabaseRepository.instance.printAllFolders();
                  },
                )
              : Container()
        ],
      ),
    );
  }
}
