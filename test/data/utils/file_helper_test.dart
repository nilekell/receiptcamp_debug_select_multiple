import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:receiptcamp/data/data_constants.dart';
import 'package:receiptcamp/data/utils/file_helper.dart';
import 'package:receiptcamp/data/utils/receipt_helper.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/models/folder.dart';

class MockFileServiceCompress extends Mock implements FlutterImageCompress {
  static Future<File?> compressFile(File imageFile, String targetPath) async {
    // ignore: unused_local_variable
    CompressFormat format;

    final fileExtension = p.extension(imageFile.path);

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
            'Exception occurred in MockFlutterImageCompress.compressFile(): Cannot compress file type: $fileExtension');
    }
 
    try {
      final result = await imageFile.copy(targetPath);
      return File(result.path);
    } on Exception catch (e) {
      print('Error in FlutterImageCompress.compressAndGetFile(): $e');
      return null;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
    return '.';
  });

  const imagePaths = [
    'test/assets/image1.png',
    'test/assets/image2.jpeg',
    'test/assets/image3.jpg'
  ];

  group('FileHelper', () {
    test('getFileSize returns correct file size', () async {
      for (final path in imagePaths) {
        String testFilePath = path;
        int expectedFileSize = await File(testFilePath).length();

        int actualFileSize = await FileService.getFileSize(testFilePath, 2);

        if (actualFileSize == -1) {
          fail('Fail size is -1, indicating an error occurred');
        }
        expect(actualFileSize, isNotNull);
        expect(actualFileSize, isA<int>());
        expect(actualFileSize, equals(expectedFileSize));
      }
    });

    test('getLocalImagePath returns valid local image path', () async {
      // iterate over ImageFileType.values
      for (final imageFileType in ImageFileType.values) {
        final actualImagePath =
            await FileService.getLocalImagePath(imageFileType);
        expect(actualImagePath, isNotNull);
        // FileService.getLocalImagePath() returns empty string when an exception occurs
        expect(actualImagePath, isNot(''));
        expect(actualImagePath, isA<String>());
      }
    });

    test(
        'deleteFileFromPath actually deletes the image at a path on local app storage',
        () async {
      for (final path in imagePaths) {
        final imageFile = File(path);
        final localReceiptImagePath =
            await FileService.getLocalImagePath(ImageFileType.png);
        final localImageFile = await imageFile.copy(localReceiptImagePath);
        await localImageFile.delete();
        expect(await localImageFile.exists(), false);
      }
    });

    test('compressFile returns a file at correct path', () async {
      // NOTE: This test DOES NOT check if compression works as FlutterImageCompress library
      // does not support interfacing of its methods - so MockFileServiceCompress just returns the file at the targetPath
      for (final imagePath in imagePaths) {
        ImageFileType imageFileType =
            ReceiptService.identifyImageFileTypeFromString(
                p.extension(imagePath));
        String localReceiptImagePath =
            await FileService.getLocalImagePath(imageFileType);
        File imageFile = File(imagePath);
        File? compressedFile =
            await MockFileServiceCompress.compressFile(imageFile, localReceiptImagePath);
        expect(compressedFile, isNotNull);
        expect(await compressedFile!.length(), lessThanOrEqualTo(await imageFile.length()));
        expect(compressedFile.path, localReceiptImagePath);
        // deleting 'compressed' files stored on local machine
        await compressedFile.delete();
      }
    });

    test('pathToUint8List returns a Uint8List', () async {
      for (final imagePath in imagePaths) {
        final uint8List = await FileService.pathToUint8List(imagePath);
        expect(uint8List, isNotNull);
        expect(uint8List, isA<Uint8List>());
        // FileService.pathToUint8List returns empty UInt8List on an exception
        expect(uint8List.length, isNot(0));
      }
    });

    test('getFileNameFromFile returns the correct file name', () {
      for (final imagePath in imagePaths) {
        final imageFile = File(imagePath);
        final fileName = FileService.getFileNameFromFile(imageFile);
        expect(fileName, isNotNull);
        expect(fileName, isA<String>());
        expect(fileName, equals(p.basename(imagePath)));
      }
    });

    test('isValidImageSize returns correct result', () async {
      for (final imagePath in imagePaths) {
        final isValidSize = await FileService.isValidImageSize(imagePath);
        expect(isValidSize, isNotNull);
        expect(isValidSize, true);
        expect(isValidSize, isA<bool>());
      }
    });

    test('tempZipFilePathGenerator returns a valid temporary zip file path', () async {
      final folder = Folder(
          id: 'testId',
          name: 'testFolder',
          lastModified: Utility.getCurrentTime(),
          parentId: rootFolderId);

      final tempZipFilePath =
          await FileService.tempZipFilePathGenerator(folder);

      expect(tempZipFilePath, isNotNull);
      expect(tempZipFilePath, isA<String>());
      expect(tempZipFilePath, endsWith('${folder.name}.zip'));
    });
  });
}
