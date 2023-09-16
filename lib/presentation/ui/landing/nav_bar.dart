import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/landing/landing_cubit.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

Widget bottomNavigationBar(int state, BuildContext context) {
  const double receiptImageScale = 1.3;

  return BottomNavigationBar(
      backgroundColor: const Color(primaryDarkBlue),
      selectedItemColor: Colors.white,
      unselectedItemColor: const Color(primaryLightBlue),
      items: [
        const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: 50,),
            label: ''),
        // Image.asset() colours can't be controlled by BottomNavigationBar selected/unselected item colour so its colours are controlled
        // by BottomNavigationBarItem icon and activeIcon
        BottomNavigationBarItem(
            icon: Image.asset('assets/receipt.png', colorBlendMode: BlendMode.srcIn, color: const Color(primaryLightBlue), scale: receiptImageScale,),
            label: '',
            activeIcon: Image.asset('assets/receipt.png', colorBlendMode: BlendMode.srcIn, color: Colors.white, scale: receiptImageScale,)),
      ],
      currentIndex: state,
      onTap: (value) => context.read<LandingCubit>().updateIndex(value),
    );
}