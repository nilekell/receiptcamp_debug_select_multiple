// ignore_for_file: avoid_types_as_parameter_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/blocs/explorer/explorer_bloc.dart';
import 'package:receiptcamp/logic/blocs/upload/upload_bloc.dart';
import 'package:receiptcamp/presentation/ui/home/app_bar.dart';
import 'package:receiptcamp/presentation/ui/home/drawer.dart';
import 'package:receiptcamp/presentation/ui/home/nav_bar.dart';

class FileExplorer extends StatefulWidget {
  const FileExplorer({super.key});

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
        listeners: [
          BlocListener<ExplorerBloc, ExplorerState>(
            listener: (context, state) {
              if (state is ExplorerLoadingState) {
                print('ExplorerLoadingState');
              } else if (state is ExplorerSuccessState) {
                print('ExplorerSuccessState');
              } else if (state is ExplorerErrorState) {
                print('ExplorerFailureState');
              } else if (state is ExplorerNavigateToHomeState) {
                Navigator.of(context).pop();
              }
            },
          ),
          BlocListener<UploadBloc, UploadState>(
            listener: (context, state) {
              if (state is UploadSuccess) {
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
        ],
        child: BlocBuilder<ExplorerBloc, ExplorerState>(builder: (context, ExplorerState) {
          return BlocBuilder<UploadBloc, UploadState>(
              builder: (context, UploadState) {
            switch (UploadState.runtimeType) {
              case ExplorerLoadingState:
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              case ExplorerErrorState:
                return const Scaffold(
                    body: Center(child: Text('Failed to show Explorer Screen')));
              default:
                return Scaffold(
                    drawer: const NavDrawer(),
                    appBar: const HomeAppBar(),
                    body: const Placeholder(),
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.endFloat,
                    floatingActionButton: FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.camera_alt),
                    ),
                    bottomNavigationBar: const NavBar());
            }
          });
        }));
  }
}
