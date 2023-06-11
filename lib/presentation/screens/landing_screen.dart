import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/landing/landing_cubit.dart';
import 'package:receiptcamp/presentation/screens/file_explorer.dart';
import 'package:receiptcamp/presentation/screens/home.dart';
import 'package:receiptcamp/presentation/ui/home/app_bar.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingCubit, int>(
      builder: (context, state) => Scaffold(
        appBar: const HomeAppBar(),
        body: _getChildBasedOnTab(state),
        bottomNavigationBar: _bottomNavigationBar(state,context),
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

  Widget _bottomNavigationBar(int state,
      BuildContext context) {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Theme.of(context).secondaryHeaderColor,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore'),
      ],
      currentIndex: state,
      onTap: (value) => context.read<LandingCubit>().updateIndex(value),
    );
  }
}