import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/landing/landing_cubit.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

Widget bottomNavigationBar(int state, BuildContext context) {
  // increasing scale, reduces receipt icon size & vice-versa
  const double receiptImageScale = 1.3;
  // moves icon down by x number of pixels without affecting the layout (and other widgets)
  const Offset iconOffset = Offset(0, 15);

  return BottomNavigationBar(
    backgroundColor: const Color(primaryDarkBlue),
    selectedItemColor: Colors.white,
    unselectedItemColor: const Color(primaryLightBlue),
    items: [
      BottomNavigationBarItem(
          icon: Transform.translate(
            offset: iconOffset,
            child: const Icon(
              Icons.home_rounded,
              size: 50,
            ),
          ),
          label: ''),
      BottomNavigationBarItem(
          icon: Transform.translate(
              offset: iconOffset,
              // Image.asset() colours can't be adjusted by BottomNavigationBar selected/unselected item colour so its colours are controlled
              // by BottomNavigationBarItem icon and activeIcon
              child: Image.asset(
                'assets/receipt.png',
                colorBlendMode: BlendMode.srcIn,
                color: const Color(primaryLightBlue),
                scale: receiptImageScale,
              )),
          label: '',
          activeIcon: Transform.translate(
              offset: iconOffset,
              child: Image.asset(
                'assets/receipt.png',
                colorBlendMode: BlendMode.srcIn,
                color: Colors.white,
                scale: receiptImageScale,
              ))),
    ],
    currentIndex: state,
    onTap: (value) => context.read<LandingCubit>().updateIndex(value),
  );
}
