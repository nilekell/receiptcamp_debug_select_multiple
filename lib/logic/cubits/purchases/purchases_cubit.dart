import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:receiptcamp/data/services/purchases.dart';

part 'purchases_state.dart';

class PurchasesCubit extends Cubit<PurchasesState> {
  PurchasesCubit() : super(PurchasesInitial());

  final PurchasesService _purchasesService = PurchasesService.instance;

  checkUserPurchaseStatus() {
    print('checkUserPurchaseStatus');
    bool userIsPro = _purchasesService.userIsPro;
    emit(PurchasesUserStatus(isPro: userIsPro));
    // emitting initial state which does nothing
    // different state means listener can be called again
    emit(PurchasesInitial());
  }

  makeProPurchase() async {
    try {
      if (_purchasesService.userIsPro) {
        // emit user is already pro state
        return;
      }
      final bool isPurchaseSuccessful =
          await _purchasesService.makeProPurchase();
      if (isPurchaseSuccessful) {
        // emit purchase success state
        emit(PurchasesSuccess());
      } else {
        // emit purchase failure state
        emit(PurchasesFailed());
      }
    } on Exception catch (e) {
      print(e.toString());
      emit(PurchasesFailed());
    }
  }

  makeProSubscriptionPurchase() async {}

  restorePurchases() async {
    try {
      await _purchasesService.restorePurchases();
      if (_purchasesService.userIsPro) {
        // emit success state
        emit(PurchasesRestoreSuccess());
      } else {
        // emit failure state
        emit(PurchasesRestoreFailed());
      }
    } on Exception catch (e) {
      print(e.toString());
      emit(PurchasesRestoreFailed());
    }
  }
}
