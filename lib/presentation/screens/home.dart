// ignore_for_file: avoid_types_as_parameter_names, non_constant_identifier_names
import 'dart:io';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/blocs/home/home_bloc.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      switch (state) {
        case HomeInitialState():
          return const CircularProgressIndicator();
        case HomeLoadingState():
          return const CircularProgressIndicator();
        case HomeErrorState():
          return const Text('Error showing receipts');
        case HomeEmptyReceiptsState():
          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(HomeInitialEvent());
            },
            child: const Center(child: Text('No receipts to show')),
          );
        case HomeLoadedSuccessState():
          return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(HomeInitialEvent());
              },
              child: ListView.builder(
                  itemCount: state.receipts.length,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(state.receipts[index].name.split('.').first),
                    onTap: () {
                      final imageProvider = Image.file(File(state.receipts[index].localPath)).image;
                      showImageViewer(context, imageProvider);
                    },);
                  }));
        default:
          print('Home Screen: ${state.toString()}');
          return Container();
      }
    });
  }
}
