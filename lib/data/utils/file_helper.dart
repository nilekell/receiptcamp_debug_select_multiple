import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart';
import 'package:pdf/pdf.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/data/services/directory_path_provider.dart';
import 'package:receiptcamp/data/utils/text_recognition.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;

class FileService {

  static const iPadSharePositionOrigin = Rect.fromLTWH(0, 0, 100, 100);

  static Future<File?> compressFile(File imageFile, String targetPath) async {
    CompressFormat format;
    final fileExtension = extension(imageFile.path);

    // final sizeBeforeCompression = await bytesToSizeString(await getFileSize(imageFile.path, 2));
    // print('file size before compression: $sizeBeforeCompression');

    // print('${basename(imageFile.path)} has extension $fileExtension');

    // ImagePicker library automatically converts all images to .jpg, so all uploaded into app via camera or library will have
    // .jpg ending
    // cunning_document_scanner library produces '.png' files
    // '.heic' case is redundant, but kept in codebase for future proofing
    switch (fileExtension) {
      case '.jpeg':
        format = CompressFormat.jpeg;
        break;
      case '.jpg':
        format = CompressFormat.jpeg;
        break;
      case '.png':
        format = CompressFormat.png;
        break;
      case '.heic':
        format = CompressFormat.heic;
        break;
      default:
        throw Exception(
            'Exception occurred in FileService.compressFile(): Cannot compress file type: $fileExtension');
    }

    try {
      // for some reason, this method actually slightly increases file size for png images
      var result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        // for jpg/jpeg files only:
        // quality: 88 -> reduced in size by ~50%
        // quality: 1 -> reduced in size by ~95%
        // quality: 30 -> reduced in size by ~95%
        // quality: 50 -> reduced in size by ~87%
        quality: 50,
        format: format,
      );
      if (result == null) {
        return null;
      } else {
        // final sizeAfterCompression = await bytesToSizeString(await getFileSize(result.path, 2));
        // print('file size after compression: $sizeAfterCompression');
        // print('filename after compression ${basename(result.path)}');
        return File(result.path);
      }
    } on Exception catch (e) {
      print('Error in FlutterImageCompress.compressAndGetFile(): $e');
      return null;
    }
  }

  static Future<void> deleteFileFromPath(String imagePath) async {
    try {
      File originalImageFile = File(imagePath);

      // deleting original quality image file
      if (await originalImageFile.exists()) {
        originalImageFile.delete();
        print('File deleted: $imagePath');
      } else {
        print('File does not exist: $imagePath');
      }
    } on Exception catch (e) {
      print('Error in deleteFileFromPath: $e');
    }
  }

  static String generateFileName(ImageFileType fileType) {
    String fileName = 'RCPT_';
    try {
      // randomInt is >= 10000 and < 100,000.
      final int randomInt = Random().nextInt(90000) + 10000;

      if (fileType == ImageFileType.png) {
        fileName = '$fileName$randomInt.png';
      } else if (fileType == ImageFileType.heic) {
        fileName = '$fileName$randomInt.heic';
      } else if (fileType == ImageFileType.jpg ||
          fileType == ImageFileType.jpeg) {
        fileName = '$fileName$randomInt.jpg';
      } else {
        throw Exception('Utilities.generateFileName(): unexpected file type');
      }

      return fileName;
    } catch (e) {
      print('Error in generateFileName: $e');
      rethrow;
    }
  }

  static Future<String> getLocalImagePath(ImageFileType imageFileType) async {
    try {
      final fileName = generateFileName(imageFileType);
      final localImagePath = '${DirectoryPathProvider.instance.appDocDirPath}/$fileName';
      return localImagePath;
    } on Exception catch (e) {
      print('Error in getLocalImagePath: $e');
      return '';
    }
  }

  static Future<int> getFileSize(String filepath, int decimals) async {
    try {
      var file = File(filepath);
      int bytes = await file.length();
      return bytes;
    } on Exception catch (e) {
      print('Error in getFileSize: $e');
      return -1;
    }
  }

  static Future<Uint8List> pathToUint8List(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final bytesList = Uint8List.fromList(bytes);
      return bytesList;
    } on Exception catch (e) {
      print('Error in pathToUint8List: $e');
      return Uint8List(0);
    }
  }

  static String getFileNameFromFile(File file) {
    try {
      final fileName = basename(file.path);
      return fileName;
    } on Exception catch (e) {
      print('Error in getFileNameFromFile: $e');
      return '';
    }
  }

  static Future<bool> isValidImageSize(String imagePath,
      [int maxSizeInMB = 20]) async {
    try {
      final sizeInBytes = await FileService.getFileSize(imagePath, 2);
      final sizeInMB = sizeInBytes / (1024 * 1024);
      // returns true when image size is less than or equal to maxSizeInMB & greater than 0 MB
      return sizeInMB <= maxSizeInMB && sizeInMB > 0;
    } on Exception catch (e) {
      print('Error in ReceiptService.isValidImageSize: $e');
      return false;
    }
  }

  // share receipt image
  static Future<void> shareReceipt(Receipt receipt) async {
    try {
      // shows platform share sheet
      await Share.shareXFiles([XFile(receipt.localPath)],
          subject: receipt.name, sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100));
    } on Exception catch (e) {
      print('Error in shareReceipt: $e');
      return;
    }
  }

  static Future<File> receiptToPdf(Receipt receipt) async {
    // creating a base pdf document
    try {
      final pw.Document pdf = pw.Document();

      // creating an image from file
      final File imageFile = File(receipt.localPath);
      final img.Image image = img.decodeImage(await imageFile.readAsBytes())!;
      // Creating a custom page format with the dimensions of the image
      final PdfPageFormat pageFormat =
          PdfPageFormat(image.width.toDouble(), image.height.toDouble());
      // creating a memory image by reading the image file as bytes, which creates an image that can be added to the PDF
      final pdfImage = pw.MemoryImage(imageFile.readAsBytesSync());

      pdf.addPage(pw.Page(
          pageFormat: pageFormat,
          build: ((context) {
            return pw.Image(pdfImage);
          })));

      final String fixedReceiptName = Utility.concatenateWithUnderscore(receipt.name);    
      final pdfFile = File('${DirectoryPathProvider.instance.tempDirPath}/$fixedReceiptName.pdf');

      return pdfFile.writeAsBytes(await pdf.save());
    } on Exception catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  static Future<void> shareReceiptAsPdf(Receipt receipt) async {
    try {
      final receiptPdf = await receiptToPdf(receipt);

      await Share.shareXFiles([XFile(receiptPdf.path)], subject: receipt.name, sharePositionOrigin: iPadSharePositionOrigin);

      // delete pdf file from local temp directory
      await FileService.deleteFileFromPath(receiptPdf.path);
    } on Exception catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  static Future<void> shareFolderAsZip(Folder folder, File zipFile) async {
    // Share the excel file
    await Share.shareXFiles([XFile(zipFile.path)], subject: folder.name,sharePositionOrigin: iPadSharePositionOrigin);

    // delete zip file from local temp directory
    await FileService.deleteFileFromPath(zipFile.path);
  }

  static Future<void> shareFolderAsExcel(Folder folder, File excelFile) async {
  
    // Share the excel file
    await Share.shareXFiles([XFile(excelFile.path)], subject: folder.name,sharePositionOrigin: iPadSharePositionOrigin);

    // delete zip file from local temp directory
    await FileService.deleteFileFromPath(excelFile.path);
  }

  static Future<List<ExcelReceipt>> gatherReceiptsFromFolder(Folder currentFolder) async {
      List<ExcelReceipt> excelReceipts = [];

      final files =
          await DatabaseRepository.instance.getFolderContents(currentFolder.id);

      for (final file in files) {
        if (file is Receipt) {
          final price = await TextRecognitionService.extractPriceFromImage(
              file.localPath);
          final excelReceipt = ExcelReceipt(
              price: price, receipt: file);
          excelReceipts.add(excelReceipt);
        } else if (file is Folder) {
          await gatherReceiptsFromFolder(file); // Recursive call
        }
      }

      return excelReceipts;
    }


  static Future<List<File>> getAllReceiptImages() async {
    List<File> receiptImages = [];

    String dirPath = '${DirectoryPathProvider.instance.appDocDirPath}/';

    Directory directory = Directory(dirPath);

    List<FileSystemEntity> files = directory.listSync();

    for (FileSystemEntity file in files) {
      String fileName = basename(file.path);
      if (fileName.startsWith('RCPT_')) {
        receiptImages.add(File(file.path));
      }
    }

    return receiptImages;
  }


  static Future<String> tempFilePathGenerator(String fileName) async {
    final tempFileFullPath = '${DirectoryPathProvider.instance.tempDirPath}/$fileName';
    return tempFileFullPath;
  }

  // download image to camera roll
  static Future<void> saveImageToCameraRoll(Receipt receipt) async {
    try {
      await GallerySaver.saveImage(receipt.localPath);
      print('image saved to camera roll');
    } on Exception catch (e) {
      print('Error in saveImageToCameraRoll: $e');
      rethrow;
    }
  }
}
