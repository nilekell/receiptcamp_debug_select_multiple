// ignore_for_file: avoid_types_as_parameter_names, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/blocs/explorer/explorer_bloc.dart';
import 'package:receiptcamp/logic/blocs/upload/upload_bloc.dart';
import 'package:receiptcamp/presentation/ui/bottom-sheet/upload_sheet.dart';
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
            create: (context) => ExplorerBloc()..add(ExplorerFetchReceiptsEvent()),
          ),
        ],
        child: MultiBlocListener(
            listeners: [
              BlocListener<UploadBloc, UploadState>(
                listener: (context, state) {
                  if (state is UploadSuccess) {
                    context.read<ExplorerBloc>().add(ExplorerFetchReceiptsEvent());
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Receipt added successfully'),
                        duration: Duration(milliseconds: 900)));
                  } else if (state is UploadFailed) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Receipt failed to be saved'),
                        duration: Duration(milliseconds: 900)));
                  }
                },
              ),
              BlocListener<ExplorerBloc, ExplorerState>(
                listener: (context, state) {
                  if (state is ExplorerNavigateToHomeState) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
            child: BlocBuilder<ExplorerBloc, ExplorerState>(
              builder: (context, state) {
                if (state is ExplorerInitialState) {
                  return const Scaffold(body: CircularProgressIndicator());
                }
                else if (state is ExplorerLoadingState) {
                  return const Scaffold(body: CircularProgressIndicator());
                }
                else if (state is ExplorerLoadedState) {
                  return RefreshIndicator(
                    onRefresh: () async {
                  context.read<ExplorerBloc>().add(ExplorerFetchReceiptsEvent());
                },
                    child: Scaffold(
                        drawer: const NavDrawer(),
                        appBar: const HomeAppBar(),
                        bottomNavigationBar: const NavBar(),
                        body: ListView.builder(
                          itemCount: state.receipts.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(state.receipts[index].name),
                            );
                          },
                        ),
                        floatingActionButtonLocation:
                            FloatingActionButtonLocation.endFloat,
                        floatingActionButton: FloatingActionButton(
                          onPressed: () => showUploadOptions(context),
                          backgroundColor: Colors.blue,
                          child: const Icon(Icons.add),
                        )),
                  );
                } else if (state is ExplorerErrorState) {
                  return const Scaffold(body: Text('Explorer Error'));
                } else if (state is ExplorerLoadingState) {
                  return const Scaffold(body: CircularProgressIndicator());
                } else {
                  return const Scaffold(body: Text('Explorer Initial State'));
                }
              },
            )));
  }
}
