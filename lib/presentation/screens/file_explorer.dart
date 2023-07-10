// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/file_system/file_system_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/presentation/ui/file_explorer/snackbars/snackbar_utility.dart';
import 'package:receiptcamp/presentation/ui/file_navigator/folder/folder_sheet.dart';
import 'package:receiptcamp/presentation/ui/file_navigator/receipt/receipt_sheet.dart';
import 'package:receiptcamp/presentation/ui/file_navigator/upload_sheet.dart';

class FileExplorer extends StatefulWidget {
  const FileExplorer({super.key});

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  @override
  void initState() {
    context.read<FileSystemCubit>().initializeFileSystemCubit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FileSystemCubit, FileSystemCubitState>(
        listenWhen: (previous, current) =>
            current is FileSystemCubitActionState,
        listener: (context, state) {
          SnackBarUtility.showFileSystemSnackBar(context, state);
        },
        builder: (context, state) {
          if (state is FileSystemCubitInitial ||
              state is FileSystemCubitLoading) {
            return const CircularProgressIndicator();
          } else if (state is FileSystemCubitFolderInformationSuccess) {
            return Scaffold(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  state.folder.id != 'a1'
                      ? FolderName(
                          name: state.folder.name,
                        )
                      : const FolderName(
                          name: 'My Receipts',
                        ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  state.folder.id != 'a1'
                      ? BackButton(
                          previousFolderId: state.folder.parentId,
                          currentFolderId: state.folder.id,
                        )
                      : Container(),
                  const Expanded(
                    child: RefreshableFolderView(),
                  )
                ],
              ),
              floatingActionButton: UploadButton(currentFolder: state.folder),
            );
          } else if (state is FileSystemCubitError) {
            return const Center(
              child: Text('Error State'),
            );
          } else {
            return const Center(
              child: Text('Unknown State'),
            );
          }
        });
  }
}

class FolderName extends StatelessWidget {
  final String name;
  const FolderName({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 34.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class BackButton extends StatelessWidget {
  final String previousFolderId;
  final String currentFolderId;

  const BackButton(
      {super.key,
      required this.previousFolderId,
      required this.currentFolderId});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          context.read<FileSystemCubit>().navigateBack(previousFolderId);
        },
        icon: const Icon(Icons.arrow_back));
  }
}

class RefreshableFolderView extends StatefulWidget {
  const RefreshableFolderView({
    Key? key,
  }) : super(key: key);

  @override
  State<RefreshableFolderView> createState() => _RefreshableFolderViewState();
}

class _RefreshableFolderViewState extends State<RefreshableFolderView> {
  List<dynamic> files = [];
  Folder? folder;

  @override
  void initState() {
   context.read<FileSystemCubit>().fetchFiles('a1');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FileSystemCubit>().refreshFiles(folder!.id);
      },
      child: BlocConsumer<FileSystemCubit, FileSystemCubitState>(
        listener: (context, state) {
          SnackBarUtility.showFileSystemSnackBar(context, state);
        },
        builder: (context, state) {
          if (state is FileSystemCubitInitial || state is FileSystemCubitLoading) {
            return const CircularProgressIndicator();
          } else if (state is FileSystemCubitFolderItemsChangedState) {
            setState(() {
              files = state.files;
            });

            return files.isNotEmpty ? ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                var item = files[index];
                if (item is Receipt) {
                  return ReceiptListTile(receipt: item);
                } else if (item is Folder) {
                  return FolderListTile(folder: item);
                }
                return null;
              },
            )
          : const Padding(
              padding: EdgeInsets.all(100.0),
              child: Text('No receipts/folders to show'),
            );
          } else if (state is FileSystemCubitLoadedSuccess) {
            setState(() {
              files = state.files;
            });

            return files.isNotEmpty ? ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                var item = files[index];
                if (item is Receipt) {
                  return ReceiptListTile(receipt: item);
                } else if (item is Folder) {
                  return FolderListTile(folder: item);
                }
                return null;
              },
            )
          : const Padding(
              padding: EdgeInsets.all(100.0),
              child: Text('No receipts/folders to show'),
            );
          } else {
            return const Text('Unknown state');
          }
          
          
        },
      )
          
    );
  }
}

class FolderListTile extends StatelessWidget {
  final Folder folder;

  const FolderListTile({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileSystemCubit, FileSystemCubitState>(
      builder: (context, state) {
        return ListTile(
          leading: const Icon(Icons.folder),
          trailing: IconButton(
            icon: Icon(
              Icons.more,
              size: 20.0,
              color: Colors.brown[900],
            ),
            onPressed: () {
              showFolderOptions(
                  context, context.read<FileSystemCubit>(), folder);
            },
          ),
          onTap: () {
            context.read<FileSystemCubit>().selectFolder(folder.id);
          },
          title: Text(folder.name),
        );
      },
    );
  }
}

class ReceiptListTile extends StatelessWidget {
  final Receipt receipt;

  const ReceiptListTile({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileSystemCubit, FileSystemCubitState>(
      builder: (context, state) {
        return ListTile(
            leading: const Icon(Icons.receipt),
            trailing: IconButton(
              icon: Icon(
                Icons.more,
                size: 20.0,
                color: Colors.brown[900],
              ),
              onPressed: () {
                showReceiptOptions(
                    context, context.read<FileSystemCubit>(), receipt);
              },
            ),
            onTap: () {
              // show receipt preview
            },
            title: Text(receipt.name.split('.').first));
      },
    );
  }
}

class UploadButton extends StatelessWidget {
  final Folder currentFolder;

  const UploadButton({super.key, required this.currentFolder});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showUploadOptions(
            context, context.read<FileSystemCubit>(), currentFolder);
      },
      child: const Icon(Icons.add),
    );
  }
}
