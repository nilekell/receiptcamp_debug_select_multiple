import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const SizedBox(
            height: 100
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
            child: Text('ReceiptCamp',
            style: TextStyle(fontSize: 25,
            fontWeight: FontWeight.bold),),
          ),
          const Divider(height: 4,),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.border_color),
            title: const Text('Feedback'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          // temporary buttons for debugging
          kDebugMode ? 
            ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete all receipts'),
            onTap: () {
              DatabaseRepository.instance.deleteAll();
            },
          ) : Container(),
          kDebugMode ? ListTile(
            leading: const Icon(Icons.print),
            title: const Text('Print all receipts'),
            onTap: () {
              DatabaseRepository.instance.printAllReceipts();
            },
          )  : Container(),
          kDebugMode ? ListTile(
            leading: const Icon(Icons.print),
            title: const Text('Print all tags'),
            onTap: () {
              DatabaseRepository.instance.printAllTags();
            },
          ) : Container()
        ],
      ),
    );
  }
}