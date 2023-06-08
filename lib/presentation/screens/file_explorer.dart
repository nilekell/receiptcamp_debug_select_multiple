// ignore_for_file: avoid_types_as_parameter_names, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/blocs/explorer/explorer_bloc.dart';
import 'package:receiptcamp/logic/blocs/upload/upload_bloc.dart';
import 'package:receiptcamp/presentation/ui/home/app_bar.dart';
import 'package:receiptcamp/presentation/ui/home/drawer.dart';
import 'package:receiptcamp/presentation/ui/home/nav_bar.dart';

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
        child: MultiBlocListener(
            listeners: [
              BlocListener<UploadBloc, UploadState>(
                listener: (context, state) {
                  switch (state) {
                    case UploadSuccess():
                      context
                          .read<ExplorerBloc>()
                          .add(ExplorerFetchReceiptsEvent());
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Receipt added successfully'),
                          duration: Duration(milliseconds: 900)));
                    case UploadFailed():
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Receipt failed to be saved'),
                          duration: Duration(milliseconds: 900)));
                    default:
                      print(state.toString());
                      return;
                  }
                },
              ),
              BlocListener<ExplorerBloc, ExplorerState>(
                listenWhen: (previous, current) =>
                    current is ExplorerActionState,
                listener: (context, state) {
                  switch (state) {
                    case ExplorerNavigateToHomeState():
                      Navigator.of(context).pop();
                    default:
                      print(state.toString());
                      return;
                  }
                },
              ),
            ],
            child: BlocBuilder<ExplorerBloc, ExplorerState>(
                buildWhen: (previous, current) =>
                    current is! ExplorerActionState,
                builder: (context, state) {
                  return Scaffold(
                      drawer: const NavDrawer(),
                      appBar: const HomeAppBar(),
                      bottomNavigationBar: const NavBar(),
                      body: BlocBuilder<ExplorerBloc, ExplorerState>(
                        builder: (context, state) {
                          switch (state) {
                            case ExplorerInitialState():
                              return const CircularProgressIndicator();
                            case ExplorerLoadingState():
                              return const CircularProgressIndicator();
                            case ExplorerEmptyReceiptsState():
                              return RefreshIndicator(
                                onRefresh: () async {
                                  context
                                      .read<ExplorerBloc>()
                                      .add(ExplorerFetchReceiptsEvent());
                                },
                                child: const Center(child: Text('No receipts to show')),
                              );
                            case ExplorerLoadedSuccessState():
                              return RefreshIndicator(onRefresh: () async {
                                context
                                    .read<ExplorerBloc>()
                                    .add(ExplorerFetchReceiptsEvent());
                              }, child: ListView.builder(
                                  itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(state.receipts[index].name),
                                );
                              }));
                            default:
                              return const Text('Unknown State');
                          }
                        },
                      ));
                })));
  }
}
