import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/landing/landing_cubit.dart';
import 'package:receiptcamp/presentation/screens/file_explorer.dart';
import 'package:receiptcamp/presentation/screens/home.dart';
import 'package:receiptcamp/presentation/ui/home/app_bar.dart';
import 'package:receiptcamp/presentation/ui/home/drawer.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingCubit, int>(
      builder: (context, state) => Scaffold(
        drawer: const NavDrawer(),
        appBar: const HomeAppBar(),
        body: _getChildBasedOnTab(state),
        bottomNavigationBar: _bottomNavigationBar(state, context),
      ),
    );
  }

  Widget _getChildBasedOnTab(int index) {
    switch (index) {
      case 0:
        return const Home();
      case 1:
        return const FileExplorer();
      default:
        return const Scaffold(
          body: Center(
            child: Text('error'),
          ),
        );
    }
  }

  Widget _bottomNavigationBar(int state, BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.blue,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Colors.black,
      items: const [
        BottomNavigationBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(Icons.home),
            label: 'Home'),
        BottomNavigationBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(Icons.folder),
            label: 'Receipts'),
      ],
      currentIndex: state,
      onTap: (value) => context.read<LandingCubit>().updateIndex(value),
    );
  }
}
