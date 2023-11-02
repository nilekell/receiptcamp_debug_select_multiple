import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/purchases/purchases_cubit.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';


class PaywallView extends StatelessWidget {
  const PaywallView({super.key});

  void _showOkDialog(BuildContext context, String message) async {
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
                      "Purchase is pending...",
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ),
          );
        }));
  }

  void _closePendingDialogAndBottomSheet(BuildContext context) {
    Navigator.of(context).pop(); // hiding pending dialog
    Navigator.of(context).pop(); // hiding bottom sheet
  }

  void _paywallPurchasesListener(BuildContext context, PurchasesState state) {
    switch (state) {
            case PurchasesPending():
              _showPurchasePendingDialog(context);
              break;
            case PurchasesSuccess():
              _closePendingDialogAndBottomSheet(context);
              _showOkDialog(
                  context, 'Purchase successful. Welcome to ReceiptCamp Pro!');
              break;
            case PurchasesFailed():
              Navigator.pop(context); // hiding pending dialog
              _showOkDialog(
                  context, 'Uh oh, purchase failed. Please try again later.');
              break;
            case PurchasesRestoreSuccess():
              _closePendingDialogAndBottomSheet(context);
              _showOkDialog(
                  context, 'Purchases successfully restored. Welcome back.');
              break;
            case PurchasesRestoreFailed():
              _closePendingDialogAndBottomSheet(context);
              _showOkDialog(context,
                  'Purchase restore failed. Please contact receiptcamp@gmail.com');
              break;
            case UserIsAlreadyPro():
              _showOkDialog(context, 'User is already pro');
              break;
            default:
              print(state.toString());
          }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<PurchasesCubit>(),
      child: BlocConsumer<PurchasesCubit, PurchasesState>(
        listener: (context, state) {
          _paywallPurchasesListener(context, state);
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
