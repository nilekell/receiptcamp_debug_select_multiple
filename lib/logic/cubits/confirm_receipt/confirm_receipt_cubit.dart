import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/data/utils/text_recognition.dart';
import 'package:receiptcamp/models/receipt.dart';

part 'confirm_receipt_state.dart';

class ConfirmReceiptCubit extends Cubit<ConfirmReceiptState> {
  ConfirmReceiptCubit() : super(ConfirmReceiptInitial());

  getInitialExcelReceipts(String folderId) async {
    emit(ConfirmReceiptInitial());
    emit(ConfirmReceiptLoading());

    try {
      final receipts =
          await DatabaseRepository.instance.getAllReceiptsInFolder(folderId);

      List<ExcelReceipt> initialReceipts = [];
      for (final receipt in receipts) {
        final price = await TextRecognitionService.extractPriceFromImage(
            receipt.localPath);
        final excelReceipt = ExcelReceipt(receipt: receipt, price: price);
        initialReceipts.add(excelReceipt);
      }

      if (initialReceipts.isEmpty) {
        emit(ConfirmReceiptEmpty());
        return;
      }

      emit(ConfirmReceiptSuccess(excelReceipts: initialReceipts));
    } on Exception catch (e) {
      print(e.toString());
      emit(ConfirmReceiptError());
    }
  }
}
