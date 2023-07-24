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
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {},
          ),
          // temporary buttons for debugging
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete all receipts'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text('Print all receipts'),
            onTap: () {
              DatabaseRepository.instance.printAllReceipts();
            },
          ),
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text('Print all tags'),
            onTap: () {
              DatabaseRepository.instance.printAllTags();
            },
          )
        ],
      ),
    );
  }
}