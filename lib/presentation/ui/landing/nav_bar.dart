import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/landing/landing_cubit.dart';

Widget bottomNavigationBar(int state, BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.blue,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.black45,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: ''),
        BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: ''),
      ],
      currentIndex: state,
      onTap: (value) => context.read<LandingCubit>().updateIndex(value),
    );
  }