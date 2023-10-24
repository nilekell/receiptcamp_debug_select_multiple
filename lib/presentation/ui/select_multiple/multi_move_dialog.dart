// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/logic/cubits/select_multple/select_multiple_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/presentation/screens/select_multiple_screen.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

Future<void> showMultiMoveDialog(BuildContext context,
    SelectMultipleCubit selectMultipleCubit, Object selectedObject, List<ListItem> itemsToBeMoved) async {
  return await showDialog(
      context: context,
      builder: (moveFolderDialogContext) {
        return BlocProvider.value(
            value: selectMultipleCubit,
            child: MultiMoveDialog(itemsToBeMoved: itemsToBeMoved, selectedObject: selectedObject,));
      });
}

class MultiMoveDialog extends StatefulWidget {
  Object selectedObject;
  final List<ListItem> itemsToBeMoved;

  MultiMoveDialog({super.key, required this.selectedObject, required this.itemsToBeMoved});

  @override
  State<MultiMoveDialog> createState() => _MultiMoveDialogState();
}

class _MultiMoveDialogState extends State<MultiMoveDialog> {
  List<Folder> folders = [];
  Folder? selectedFolder;
  // if there are any possible folders that the current folder can be moved to, [availableFolders] = true
  bool availableFolders = true;
  bool currentFolderIsSelected = false;

  Folder? thisFolder;
  Receipt? thisReceipt;


  @override
  void initState() {
    super.initState();
    determineThisItemType();
    loadFolders();
  }

  void determineThisItemType() {
    final itemOption = widget.selectedObject;
    if (itemOption is Receipt) {
      thisReceipt = itemOption;
    } else if (itemOption is Folder) {
      thisFolder = itemOption;
    }
  }

  // this method is only called once, when the widget is inserted into them widget tree
  Future<void> loadFolders() async {
    // getting all folders except for the folders to be moved, their parent folders, and  any of their child folders and subfolders
    // this ensure we don't show any folders that are illogical to move to in the dropdown menu
    final List<Object> objectsToBeMoved = List.generate(widget.itemsToBeMoved.length,
        (index) => widget.itemsToBeMoved[index].item);
    folders = await DatabaseRepository.instance
        .getMultiFoldersThatCanBeMovedTo(objectsToBeMoved);
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
      title: Text( widget.itemsToBeMoved.length > 1 ?
        'Move ${widget.itemsToBeMoved.length} items to...' :
        'Move ${widget.itemsToBeMoved.length} item to...',
        textAlign: TextAlign.left,
        style: const TextStyle(color: Colors.white),
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
            iconSize: 35,
            iconEnabledColor: Colors.white,
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
                  child: Text(folder.name,
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
                  // call move items method
                  context.read<SelectMultipleCubit>().moveMultiItems(selectedFolder!.id, widget.itemsToBeMoved);
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
