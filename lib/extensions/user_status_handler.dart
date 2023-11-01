import 'package:flutter/material.dart';
import 'package:receiptcamp/data/services/purchases.dart';
import 'package:receiptcamp/presentation/screens/paywall.dart';

extension UserStatusHandler on BuildContext {
  void handleUserStatus(Function onPro) {
    print('handleUserStatus');
    final PurchasesService purchasesService = PurchasesService.instance;
    purchasesService.checkCustomerPurchaseStatus();
    if (purchasesService.userIsPro) {
      onPro(this);
    } else {
      Navigator.of(this).pop();
      showModalBottomSheet(
        context: this,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return PaywallView();
        },
      );
    }
  }
}
