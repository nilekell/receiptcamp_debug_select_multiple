import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receiptcamp/data/utils/utilities.dart';

class FileService {
  static Future<File?> compressFile(File imageFile, String targetPath) async {
    try {
      var result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 88,
        format: CompressFormat.jpeg,
      );
      if (result == null) {
        return null;
      } else {
        return File(result.path);
      }
    } on Exception catch (e) {
      print('Error in compressFile: $e');
      return null;
    }
  }

  static Future<void> deleteImageFromPath(String imagePath) async {
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
      print('Error in deleteImageFromPath: $e');
    }
  }

  static Future<String> getLocalImagePath() async {
    try {
      Directory imageDirectory = await getApplicationDocumentsDirectory();
      String imageDirectoryPath = imageDirectory.path;
      final fileName = Utility.generateFileName();
      final localImagePath = '$imageDirectoryPath/$fileName';

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

  // convert bytes to string that represents file sizes
  static Future<String> bytesToSizeString(int bytes) async {
    try {
      if (bytes <= 0) return "0 B";
      const suffixes = ["B", "KB", "MB", "GB"];
      var i = (log(bytes) / log(1024)).floor();
      return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
    } on Exception catch (e) {
      print('Error in bytesToSizeString: $e');
      return '';
    }
  }
}
