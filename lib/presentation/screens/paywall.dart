import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/purchases/purchases_cubit.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';


class PaywallView extends StatelessWidget {
  const PaywallView({super.key});

  Future<void> _showDialog(BuildContext context, String message) async {
    showAdaptiveDialog(
        context: context,
        builder: (context) {
          return AlertDialog.adaptive(
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Ok')),
            ],
          );
        });
  }

  Future<void> _showPurchasePendingDialog(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: ((context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(40.0))),
            backgroundColor: const Color(primaryDeepBlue),
            content: Row(
              children: [
                const CircularProgressIndicator(),
                Container(
                    margin: const EdgeInsets.only(left: 16),
                    child: const Text(
                      "pending",
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ),
          );
        }));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<PurchasesCubit>(),
      child: BlocConsumer<PurchasesCubit, PurchasesState>(
        listener: (context, state) async {
          if (state is PurchasesPending) {
            _showPurchasePendingDialog(context);
          } else if (state is PurchasesSuccess) {
            _showDialog(context, 'Purchase successful. Welcome to ReceiptCamp Pro!');
            Navigator.of(context).pop();
          } else if (state is PurchasesFailed) {
            await _showDialog(context, 'Uh oh, purchase failed. Please try again later.');
            if (context.mounted) Navigator.of(context).pop();
          } else if (state is PurchasesRestoreSuccess) {
            await _showDialog(context, 'Purchases Successfully restored. Welcome back.');
          } else if (state is PurchasesRestoreFailed) {
            await _showDialog(context, 'Purchase restore failed. Please contact receiptcamp@gmail.com');
          } else if (state is UserIsAlreadyPro) {
            await _showDialog(context, 'User is already pro');
          } else {
            print(state.toString());
          }
        },
        builder: (context, state) {
          return GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {},
                child: DraggableScrollableSheet(
                  initialChildSize: 0.9,
                  minChildSize: 0.8,
                  maxChildSize: 1.0,
                  builder: (BuildContext context, ScrollController scrollController) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color:Color(primaryLightBlue),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: ListView(
                        controller: scrollController,
                        children: [
                          const Text(
                            'Upgrade to Pro',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          const Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Unlock premium features', style: TextStyle(fontSize: 24,color: Colors.white, fontWeight: FontWeight.bold)),
                              )
                              
                            ],
                          ),
                            ElevatedButton(
                              onPressed: () {
                                context.read<PurchasesCubit>().makeProPurchase();
                              },
                              child: const Text('Upgrade to Pro', style: TextStyle(color: Colors.white),),
                            ),
                          const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<PurchasesCubit>().restorePurchases();
                              },
                              child: const Text('Restore Purchases'),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
