import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/landing/landing_cubit.dart';

Widget bottomNavigationBar(int state, BuildContext context) {
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