import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/services/purchases.dart';
import 'package:receiptcamp/logic/cubits/purchases/purchases_cubit.dart';
import 'package:receiptcamp/presentation/screens/paywall.dart';

extension UserStatusHandler on BuildContext {
  void handleUserStatus(Function onPro) {
    print('handleUserStatus');
    final PurchasesService purchasesService = PurchasesService.instance;
    purchasesService.checkCustomerPurchaseStatus();
    if (purchasesService.userIsPro) {
      // callback to whatever pro feature the user was trying to accomplish
      onPro(this);
    } else {
      // show paywall when user is not a pro user
      Navigator.of(this).pop();
      showModalBottomSheet(
        context: this,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return BlocProvider(
        create: ((context) => PurchasesCubit()),
        child: const PaywallView(),);
        },
      );
    }
  }
}
