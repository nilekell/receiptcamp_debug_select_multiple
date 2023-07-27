import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/models/folder.dart';

Future<void> showMoveFolderDialog(BuildContext context,
    FolderViewCubit folderViewCubit, Folder thisFolder) async {
  return await showDialog(
      context: context,
      builder: (moveFolderDialogContext) {
        return BlocProvider.value(
            value: folderViewCubit,
            child: MoveFolderDialog(thisFolder: thisFolder));
      });
}

class MoveFolderDialog extends StatefulWidget {
  final Folder thisFolder;

  const MoveFolderDialog({super.key, required this.thisFolder});

  @override
  State<MoveFolderDialog> createState() => _MoveFolderDialogState();
}

class _MoveFolderDialogState extends State<MoveFolderDialog> {
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
    // getting all folders except for the folder to be moved, its parent folder, and  any of its child folders and subfolders
    // this ensure we don't show any folders that are illogical to move to in the dropdown menu
    folders = await DatabaseRepository.instance
        .getFoldersThatCanBeMovedTo(widget.thisFolder.id, widget.thisFolder.parentId);
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
      // single child scroll view prevents dropdown menu overflow
      content: SingleChildScrollView(
        child: Center(
          child: DropdownButton<Folder>(
            value: selectedFolder,
            hint: const Text('Select folder'),
            iconSize: 35,
            isDense: true,
            isExpanded: true,
            underline: Container(height: 1, color: Colors.blue,),
            // mapping the list of folders to a list of DropdownMenuItem widgets
            items: folders.map<DropdownMenuItem<Folder>>((Folder folder) {
              return DropdownMenuItem<Folder>(
                  value: folder, child: Text(folder.name));
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
            child: const Text('Cancel'),
            onPressed: () {
              // closing folder dialog
              Navigator.of(context).pop();
            }),
        TextButton(
          // disable button when a folder hasn't been selected yet OR there are no available folders that can be moved to
          onPressed: selectedFolder != null && !availableFolders
              ? () {
            // closing folder dialog
            Navigator.of(context).pop();
            context.read<FolderViewCubit>().moveFolder(widget.thisFolder, selectedFolder!.id);
          } : null,
          child: const Text('Move'),
        ),
      ],
    );
  }
}
