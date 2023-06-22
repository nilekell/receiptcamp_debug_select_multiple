// ignore_for_file: avoid_types_as_parameter_names, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/blocs/explorer/explorer_bloc.dart';
import 'package:receiptcamp/logic/blocs/upload/upload_bloc.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/presentation/ui/file_navigator/upload_sheet.dart';

class FileExplorer extends StatefulWidget {
  const FileExplorer({Key? key}) : super(key: key);

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  @override
  void initState() {
    super.initState();
    context.read<ExplorerBloc>().add(ExplorerInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<UploadBloc>(
            create: (context) => UploadBloc()..add(UploadInitialEvent()),
          ),
          BlocProvider<ExplorerBloc>(
            create: (context) => ExplorerBloc()..add(ExplorerFetchFilesEvent()),
          ),
        ],
        child: BlocConsumer<UploadBloc, UploadState>(
          listener: (context, state) {
            switch (state) {
              case UploadReceiptSuccess():
                context.read<ExplorerBloc>().add(ExplorerFetchFilesEvent());
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Receipt ${state.receipt.name} added successfully'),
                    duration: const Duration(milliseconds: 1300)));
              case UploadFolderSuccess():
                context.read<ExplorerBloc>().add(ExplorerFetchFilesEvent());
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text('Folder ${state.folder.name} added successfully'),
                    duration: const Duration(milliseconds: 1300)));
              case UploadFailed():
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Failed to save file object'),
                    duration: Duration(milliseconds: 900)));
              default:
                print('Explorer Screen: ${state.toString()}');
                return;
            }
          },
          builder: (context, state) {
            return BlocBuilder<ExplorerBloc, ExplorerState>(
              builder: (context, state) {
                switch (state) {
                  case ExplorerInitialState():
                    return const CircularProgressIndicator();
                  case ExplorerLoadingState():
                    return const CircularProgressIndicator();
                  case ExplorerEmptyReceiptsState():
                    return Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: RefreshIndicator(
                              onRefresh: () async {
                                context
                                    .read<ExplorerBloc>()
                                    .add(ExplorerFetchFilesEvent());
                              },
                              child: const Center(
                                  child: Text('No files/folders to show'))),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: FloatingActionButton.large(
                                onPressed: () {
                                  showUploadOptions(
                                      context, context.read<UploadBloc>());
                                },
                                child: const Icon(Icons.add)),
                          ),
                        ),
                      ],
                    );
                  case ExplorerLoadedSuccessState():
                    return Stack(
                      children: [
                        Align(
                            alignment: Alignment.topCenter,
                            child: RefreshIndicator(
                                onRefresh: () async {
                                  context
                                      .read<ExplorerBloc>()
                                      .add(ExplorerFetchFilesEvent());
                                },
                                child: ListView.builder(
                                  itemCount: state.files.length,
                                  itemBuilder: (context, index) {
                                    final file = state.files[index];

                                    if (file is Receipt) {
                                      return ListTile(
                                        title: Text(file.name),
                                        // can return some properties specific to Receipt
                                      );
                                    } else if (file is Folder) {
                                      return ListTile(
                                        title: Text(file.name),
                                        // can return some properties specific to Folder
                                      );
                                    } else {
                                      return const ListTile(
                                        title: Text('Unknown file'),
                                      );
                                    }
                                  },
                                ))),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: FloatingActionButton.large(
                                onPressed: () {
                                  showUploadOptions(
                                      context, context.read<UploadBloc>());
                                },
                                child: const Icon(Icons.add)),
                          ),
                        ),
                      ],
                    );
                  default:
                    print('Explorer Screen: ${state.toString()}');
                    return Container();
                }
              },
            );
          },
        ));
  }
}
