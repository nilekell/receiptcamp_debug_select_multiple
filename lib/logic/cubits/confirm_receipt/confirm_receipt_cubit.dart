import 'dart:io';
import 'dart:isolate';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/data/services/isolate.dart';
import 'package:receiptcamp/data/utils/file_helper.dart';
import 'package:receiptcamp/data/utils/text_recognition.dart';
import 'package:receiptcamp/models/folder.dart';
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

  generateExcelFile(List<ExcelReceipt> excelReceipts, Folder folder) async {
    emit(ConfirmReceiptFileLoading(excelReceipts: excelReceipts));

    try {
      List<Map<String, dynamic>> serializedReceipts =
          excelReceipts.map((e) => e.toMap()).toList();
      Map<String, dynamic> serializedFolder = folder.toMap();

      Map<String, dynamic> computeParams = {
        'excelReceipts': serializedReceipts,
        'folder': serializedFolder,
      };

      // Prepare data to pass to isolate
      final isolateParams = IsolateParams(
        computeParams: computeParams,
        rootToken: RootIsolateToken.instance!, // Replace with actual token
      );

      final receivePort = ReceivePort();
      await Isolate.spawn(IsolateService.excelEntryFunction, {
        'isolateParams': isolateParams,
        'sendPort': receivePort.sendPort,
      });

      // Receive data back from the isolate
      final File excelFile = await receivePort.first;

      emit(ConfirmReceiptFileLoaded(
          excelFile: excelFile, excelReceipts: excelReceipts));
    } on Exception catch (e) {
      print(e.toString());
      emit(ConfirmReceiptFileError(excelReceipts: List<ExcelReceipt>.empty()));
    }
  }

  shareExcelFile(File excelFile, Folder folder) async {
    await FileService.shareFolderAsExcel(folder, excelFile);
    emit(ConfirmReceiptFileClose(excelReceipts: List<ExcelReceipt>.empty()));
  }
}
