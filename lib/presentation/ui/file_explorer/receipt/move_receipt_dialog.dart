import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/data_constants.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

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
  Folder? selectedFolder;
  // if there are any possible folders that the current folder can be moved to, [availableFolders] = true
  bool availableFolders = true;
  bool currentFolderIsSelected = false;

  @override
  void initState() {
    super.initState();
    loadFolders();
  }

  // this method is only called once, when the widget is inserted into them widget tree
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

  final actionTextStyle = const TextStyle(color: Colors.white, fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40.0))),
      backgroundColor: const Color(primaryDarkBlue),
      title: const Text(
        'Move to...',
        textAlign: TextAlign.left,
        style: TextStyle(color: Colors.white),
      ),
      // single child scroll view prevents dropdown menu overflow
      content: SingleChildScrollView(
        child: Center(
          child: DropdownButton<Folder>(
            value: selectedFolder,
            hint: const Text(
              'Select folder',
              style: TextStyle(color: Colors.white),
            ),
            iconEnabledColor: Colors.white,
            iconSize: 35,
            dropdownColor: const Color(primaryDeepBlue),
            isDense: true,
            isExpanded: true,
            underline: Container(
              height: 1,
              color: Colors.white,
            ),
            // mapping the list of folders to a list of DropdownMenuItem widgets
            items: folders.map<DropdownMenuItem<Folder>>((Folder folder) {
              return DropdownMenuItem<Folder>(
                  value: folder,
                  child: Text(folder.id == rootFolderId ? 'Expenses' : folder.name,
                      style: const TextStyle(color: Colors.white)));
            }).toList(), // converting the Iterable returned from .map() back to a list
            // onChanged is called when the user selects a new option from the dropdown menu
            onChanged: (Folder? value) {
              setState(() {
                // updating the user selected value to be stored as the selectedFolder
                selectedFolder = value;
              });
            },
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
            child: Text(
              'Cancel',
              style: actionTextStyle,
            ),
            onPressed: () {
              // closing folder dialog
              Navigator.of(context).pop();
            }),
        TextButton(
          // disable button when a folder hasn't been selected yet OR there are no available folders that can be moved to
          onPressed: selectedFolder != null && availableFolders
              ? () {
                  // closing folder dialog
                  Navigator.of(context).pop();
                  context
                      .read<FolderViewCubit>()
                      .moveReceipt(widget.receipt, selectedFolder!.id);
                }
              : null,
          child: Text(
            'Move',
            style: availableFolders
                ? actionTextStyle
                : actionTextStyle.copyWith(color: const Color(0xFFBDBDBD)),
          ),
        ),
      ],
    );
  }
}
