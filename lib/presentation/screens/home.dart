// ignore_for_file: avoid_types_as_parameter_names, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/blocs/home/home_bloc.dart';
import 'package:receiptcamp/logic/blocs/upload/upload_bloc.dart';
import 'package:receiptcamp/presentation/ui/home/app_bar.dart';
import 'package:receiptcamp/presentation/ui/home/drawer.dart';
import 'package:receiptcamp/presentation/ui/home/nav_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
        listeners: [
          BlocListener<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is HomeLoadingState) {
                print('HomeLoadingState');
              } else if (state is HomeSuccessState) {
                print('HomeSuccessState');
              } else if (state is HomeErrorState) {
                print('HomeFailureState');
              } else if (state is HomeNavigateToFileExplorerState) {
                Navigator.of(context).pushNamed('/explorer');
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
        child: BlocBuilder<HomeBloc, HomeState>(builder: (context, HomeState) {
          return BlocBuilder<UploadBloc, UploadState>(
              builder: (context, UploadState) {
            switch (UploadState.runtimeType) {
              case HomeLoadingState:
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              case HomeErrorState:
                return const Scaffold(
                    body: Center(child: Text('Failed to show Home Screen')));
              default:
                return Scaffold(
                    drawer: const NavDrawer(),
                    appBar: const HomeAppBar(),
                    body: const Placeholder(),
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.endFloat,
                    floatingActionButton: FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.camera_alt),
                    ),
                    bottomNavigationBar: const NavBar());
            }
          });
        }));
  }
}
