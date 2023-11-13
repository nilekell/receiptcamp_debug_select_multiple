import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart';
import 'package:receiptcamp/data/services/directory_path_provider.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/models/receipt.dart';

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

  static Future<void> deleteAllReceiptImages() async {
    String dirPath = '${DirectoryPathProvider.instance.appDocDirPath}/';

    Directory directory = Directory(dirPath);

    List<FileSystemEntity> files = directory.listSync();

    for (FileSystemEntity file in files) {
      String fileName = basename(file.path);
      if (fileName.startsWith('RCPT_')) {
        await file.delete();
      } else {
        continue;
      }
    }
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
