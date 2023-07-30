import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';

Future<void> showMoveReceiptDialog(BuildContext context,
    FolderViewCubit folderViewCubit, Receipt receipt) async {
  return await showDialog(
      context: context,
      builder: (moveReceiptDialogContext) {
        return BlocProvider.value(
            value: folderViewCubit,
            child: MoveReceiptDialog(receipt: receipt));
      });
}

class MoveReceiptDialog extends StatefulWidget {
  final Receipt receipt;

  const MoveReceiptDialog({super.key, required this.receipt});

  @override
  State<MoveReceiptDialog> createState() => _MoveReceiptDialogState();
}

class _MoveReceiptDialogState extends State<MoveReceiptDialog> {
  List<Folder> folders = [];
  // if there are any possible folders that the current folder can be moved to, [availableFolders] = true
  bool availableFolders = true;
  Folder? selectedFolder;

  @override
  void initState() {
    super.initState();
    loadFolders();
  }

  Future<void> loadFolders() async {
    folders = await DatabaseRepository.instance.getFoldersThatCanBeMovedTo(widget.receipt.id, widget.receipt.parentId);
    if (folders.isNotEmpty) {
      setState(() {
        selectedFolder = folders[0];
      });
    } else if (folders.isEmpty) {
      setState(() {
        availableFolders = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Move to...'),
      content: SingleChildScrollView(
        child: Center(
          child: DropdownButton<Folder>(
            value: selectedFolder,
            isDense: true,
            isExpanded: true,
            hint: const Text('Select folder'),
            items: folders.map<DropdownMenuItem<Folder>>((Folder folder) {
              return DropdownMenuItem<Folder>(
                  value: folder,child: Text(folder.name));
            }).toList(),
            onChanged: (Folder? value) {
              setState(() {
                selectedFolder = value;
              });
            },
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        TextButton(
          // disable button when a folder hasn't been selected yet OR there are no available folders that can be moved to
          onPressed: selectedFolder != null && availableFolders
              ? () {
            // closing folder dialog
            Navigator.of(context).pop();
            context.read<FolderViewCubit>().moveReceipt(widget.receipt, selectedFolder!.id);
          } : null,
          child: const Text('Move'),
        ),
      ],
    );
  }
}
