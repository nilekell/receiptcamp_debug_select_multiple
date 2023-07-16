import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/file_system/file_system_cubit.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
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
    return Scaffold(
      body: BlocBuilder<FileSystemCubit, FileSystemCubitState>(
          builder: ((context, state) {
        switch (state) {
          case FileSystemCubitInitial() || FileSystemCubitLoading():
            return const CircularProgressIndicator();
          case FileSystemCubitFolderInformationSuccess():
            return Column(
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
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 30, 30),
                      child: UploadButton(currentFolder: state.folder),
                    ),
                  ],
                )
              ],
            );
          case FileSystemCubitError():
            print(
                'FileSystemCubitError with state: ${state.runtimeType.toString()}');
            return const Center(
              child: Text('Error State'),
            );
          default:
            print(
                'FileExplorer BlocBuilder - Unaccounted for state: ${state.runtimeType.toString()}');
            return Container();
        }
      })),
    );
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
  const RefreshableFolderView({super.key});

  @override
  State<RefreshableFolderView> createState() => _RefreshableFolderViewState();
}

class _RefreshableFolderViewState extends State<RefreshableFolderView> {
  @override
  void initState() {
    print('RefreshableFolderView instantiated');
    context.read<FolderViewCubit>().initFolderView('a1');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FileSystemCubit, FileSystemCubitState>(
        listener: (context, state) {
          switch (state) {
            case FileSystemCubitFolderInformationSuccess():
              print('RefreshableFolderView: fetchFiles for ${state.folder.name}');
              context.read<FolderViewCubit>().fetchFiles(state.folder.id);
            default:
              print('RefreshableFolderViewState: ${state.toString()}');
          }
        },
        child: BlocConsumer<FolderViewCubit, FolderViewState>(
          listenWhen: (previous, current) => current is FolderViewActionState,
          listener: (context, state) {
            SnackBarUtility.showSnackBar(context, state);
          },
          builder: (context, state) {
            switch (state) {
              case FolderViewInitial() || FolderViewLoading():
                return const CircularProgressIndicator();
              case FolderViewLoadedSuccess():
              print('FolderView built with folder: ${state.folder.name}');
                return RefreshIndicator(
                  onRefresh: () async {
                    print('refreshing folder ${state.folder.name}');
                    context.read<FolderViewCubit>().fetchFiles(state.folder.id);
                  },
                  child: state.files.isNotEmpty
                      ? ListView.builder(
                          itemCount: state.files.length,
                          itemBuilder: (context, index) {
                            var item = state.files[index];
                            if (item is Receipt) {
                              return ReceiptListTile(receipt: item);
                            } else if (item is Folder) {
                              return FolderListTile(folder: item);
                            } else {
                              return const ListTile(
                                  title: Text('Unknown file type'));
                            }
                          },
                        )
                      : const Padding(
                          padding: EdgeInsets.all(100.0),
                          child: Text('No receipts/folders to show'),
                        ),
                );
              case FolderViewError():
                print(
                    'FolderViewCubitError with state: ${state.runtimeType.toString()}');
                return const Center(
                  child: Text('Error State'),
                );
              default:
                print(
                    'RefreshableFolderView BlocBuilder - Unaccounted for state: ${state.runtimeType.toString()}');
                return Container();
            }
          },
        ));
  }
}

class FolderListTile extends StatelessWidget {
  final Folder folder;

  const FolderListTile({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.folder),
      trailing: IconButton(
        icon: Icon(
          Icons.more,
          size: 20.0,
          color: Colors.brown[900],
        ),
        onPressed: () {
          showFolderOptions(context, context.read<FolderViewCubit>(), folder);
        },
      ),
      onTap: () {
        context.read<FileSystemCubit>().selectFolder(folder.id);
      },
      title: Text(folder.name),
    );
  }
}

class ReceiptListTile extends StatelessWidget {
  final Receipt receipt;

  const ReceiptListTile({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
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
                context, context.read<FolderViewCubit>(), receipt);
          },
        ),
        onTap: () {
          // show receipt preview
        },
        title: Text(receipt.name.split('.').first));
  }
}

class UploadButton extends StatelessWidget {
  final Folder currentFolder;

  const UploadButton({super.key, required this.currentFolder});

  @override
  Widget build(BuildContext context) {
    print('UploadButton built with folder: ${currentFolder.name}');
    return FloatingActionButton(
      onPressed: () {
        showUploadOptions(
            context, context.read<FolderViewCubit>(), currentFolder);
      },
      child: const Icon(Icons.add),
    );
  }
}
