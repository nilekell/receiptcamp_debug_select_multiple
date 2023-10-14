import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class IsolateParams {
  final Map<String, dynamic> computeParams;
  final RootIsolateToken rootToken;

  IsolateParams({
    required this.computeParams,
    required this.rootToken,
  });
}

abstract class IsolateService {
  
  static void excelEntryFunction(Map<String, dynamic> args) async {
    final IsolateParams isolateParams = args['isolateParams'];
    final SendPort sendPort = args['sendPort'];

    BackgroundIsolateBinaryMessenger.ensureInitialized(isolateParams.rootToken);

    final File resultFile =
        await _createExcelSheetfromReceipts(isolateParams.computeParams);

    sendPort.send(resultFile);
  }

  static FutureOr<File> _createExcelSheetfromReceipts(
    Map<String, dynamic> computeParams) async {
  final List<Map<String, dynamic>> serializedReceipts =
      computeParams['excelReceipts'];
  final Map<String, dynamic> serializedFolder = computeParams['folder'];

  final List<ExcelReceipt> excelReceipts =
      serializedReceipts.map((e) => ExcelReceipt.fromMap(e)).toList();
  final Folder folder = Folder.fromMap(serializedFolder);

  final Workbook workbook = Workbook();
  final Worksheet sheet = workbook.worksheets[0];

  final Style headingStyle = workbook.styles.add('HeadingStyle');
  headingStyle.bold = true;
  headingStyle.hAlign = HAlignType.center;

  sheet.getRangeByName('A1').setText('Name');
  sheet.getRangeByName('A1').cellStyle = headingStyle;
  sheet.getRangeByName('B1').setText('Price');
  sheet.getRangeByName('B1').cellStyle = headingStyle;
  sheet.getRangeByName('C1').setText('Date Created');
  sheet.getRangeByName('C1').cellStyle = headingStyle;
  sheet.getRangeByName('D1').setText('Folder Name');
  sheet.getRangeByName('D1').cellStyle = headingStyle;
  sheet.getRangeByName('E1').setText('File Name');
  sheet.getRangeByName('E1').cellStyle = headingStyle;

  int rowIndex = 2;
  const double columnWidth = 25.0;

  for (final excelReceipt in excelReceipts) {
    sheet.getRangeByName('A$rowIndex').setText(excelReceipt.name);
    sheet.getRangeByName('A$rowIndex').columnWidth = columnWidth;

    sheet.getRangeByName('B$rowIndex').setText(excelReceipt.price);
    sheet.getRangeByName('B$rowIndex').columnWidth = columnWidth;

    sheet.getRangeByName('C$rowIndex').setText(Utility.formatDateTimeFromUnixTimestamp(excelReceipt.dateCreated));
    sheet.getRangeByName('C$rowIndex').columnWidth = columnWidth;

    final folder = await DatabaseRepository.instance.getFolderById(excelReceipt.parentId);
    sheet.getRangeByName('D$rowIndex').setText(folder.name);
    sheet.getRangeByName('D$rowIndex').columnWidth = columnWidth;

    sheet.getRangeByName('E$rowIndex').setText(excelReceipt.fileName);
    sheet.getRangeByName('E$rowIndex').columnWidth = columnWidth;

    rowIndex++;
  }

  int imageStartRow = rowIndex + 5;
  int imageColIndex = 0;

  for (final excelReceipt in excelReceipts) {
    final String appDocDirPath = (await getApplicationDocumentsDirectory()).path;
    img.Image? receiptImage = decodeImage(File('$appDocDirPath/${excelReceipt.fileName}').readAsBytesSync());

    if (receiptImage != null) {
      final List<int> bytes = File('$appDocDirPath/${excelReceipt.fileName}').readAsBytesSync();
      const int maxCellDimension = 100;
      double aspectRatio = receiptImage.width / receiptImage.height;
      int newWidth, newHeight;

      if (aspectRatio >= 1) {
        newWidth = maxCellDimension;
        newHeight = (maxCellDimension / aspectRatio).floor();
      } else {
        newHeight = maxCellDimension;
        newWidth = (maxCellDimension * aspectRatio).floor();
      }

      if (imageColIndex == 5) {
        imageStartRow += 15; 
        imageColIndex = 0;
      }

      sheet.getRangeByIndex(imageStartRow, imageColIndex + 1).setText(excelReceipt.name);
      final picture = sheet.pictures.addStream(imageStartRow + 1, imageColIndex + 1, bytes);
      
      picture.width = newWidth * 2;
      picture.height = newHeight * 2;

      imageColIndex++;
    }
  }

  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();
  String tempXlsxFileFullPath = '${(await getTemporaryDirectory()).path}/${folder.name}.xlsx';
  final excelFile = await File(tempXlsxFileFullPath).writeAsBytes(bytes);

  return excelFile;
}
}
