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
        if (state is HomeNavigateToFileExplorerState) {
          Navigator.of(context).pushNamed('/explorer');
        }
      },
      builder: (context, state) {
        if (state is HomeInitialState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is HomeLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is HomeLoadedReceiptsState) {
          return Scaffold(
            drawer: const NavDrawer(),
            appBar: const HomeAppBar(),
            bottomNavigationBar: const NavBar(),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(HomeLoadReceiptsEvent());
              },
              child: ListView.builder(
                itemCount: state.receipts.length,
                itemBuilder: (context, index) {
                  // replace this with your own logic
                  return ListTile(
                    title: Text(state.receipts[index].name),
                  );
                },
              ),
            ),
          );
        } else {
          // this runs when state is HomeErrorState
          return const Scaffold(
              body: Center(child: Text('Failed to show Home Screen')));
        }
      },
    );
  }
}
