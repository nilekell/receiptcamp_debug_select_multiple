// ignore_for_file: avoid_types_as_parameter_names, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/blocs/explorer/explorer_bloc.dart';
import 'package:receiptcamp/logic/blocs/upload/upload_bloc.dart';
import 'package:receiptcamp/presentation/ui/bottom-sheet/upload_sheet.dart';

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
            create: (context) =>
                ExplorerBloc()..add(ExplorerFetchReceiptsEvent()),
          ),
        ],
        child: BlocConsumer<UploadBloc, UploadState>(
          listener: (context, state) {
            switch (state) {
              case UploadSuccess():
                context.read<ExplorerBloc>().add(ExplorerFetchReceiptsEvent());
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Receipt added successfully'),
                    duration: Duration(milliseconds: 900)));
              case UploadFailed():
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Receipt failed to be saved'),
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
                                    .add(ExplorerFetchReceiptsEvent());
                              },
                              child: const Center(
                                  child: Text('No receipts to show'))),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: FloatingActionButton.large(
                                onPressed: () {
                                  showUploadOptions(context, context.read<UploadBloc>());
                                }, child: const Icon(Icons.add)),
                          ),
                        ),
                      ],
                    );
                  case ExplorerLoadedSuccessState():
                    return Stack(
                      children: [
                        Align(
                            alignment: Alignment.topCenter,
                            child: RefreshIndicator(onRefresh: () async {
                              context
                                  .read<ExplorerBloc>()
                                  .add(ExplorerFetchReceiptsEvent());
                            }, child:
                                ListView.builder(
                                  itemCount: state.receipts.length,
                                  itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(state.receipts[index].name),
                              );
                            }))),
                         Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: FloatingActionButton.large(
                                onPressed: () {
                                  context.read<UploadBloc>().add(UploadTapEvent());
                                }, child: const Icon(Icons.add)),
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
