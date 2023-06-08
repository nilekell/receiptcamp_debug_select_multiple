// ignore_for_file: avoid_types_as_parameter_names, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/blocs/home/home_bloc.dart';
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
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        switch (state) {
          case HomeNavigateToFileExplorerState():
            Navigator.of(context).pushNamed('/explorer');
          default:
            print(state.toString());
            return;
        }
      },
      builder: (context, state) {
        return Scaffold(
            drawer: const NavDrawer(),
            appBar: const HomeAppBar(),
            bottomNavigationBar: const NavBar(),
            body: BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
              switch (state) {
                case HomeInitialState():
                  return const CircularProgressIndicator();
                case HomeLoadingState():
                  return const CircularProgressIndicator();
                case HomeErrorState():
                  return const Text('Error showing receipts');
                case HomeLoadedReceiptsState():
                  return RefreshIndicator(
                      onRefresh: () async {
                        context.read<HomeBloc>().add(HomeLoadReceiptsEvent());
                      },
                      child: ListView.builder(
                          itemCount: state.receipts.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                                title: Text(state.receipts[index].name));
                          }));
                default:
                  return const Text('Unknown State');
              }
            }));
      },
    );
  }
}
