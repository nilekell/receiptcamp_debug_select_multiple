import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p hide equals;
import 'package:receiptcamp/data/data_constants.dart';
import 'package:receiptcamp/data/services/database.dart';
import 'package:receiptcamp/data/utils/file_helper.dart';
import 'package:receiptcamp/data/utils/receipt_helper.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MockFileServiceCompress extends Mock {
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

class MockFileServiceShareFolderAsZip extends Mock {
  // share folder outside of app
  static Future<File?> shareFolderAsZip(Folder folder) async {
    final dbService = DatabaseService.instance;

    final archive = Archive();

    Future<void> processFolder(Folder folder, [String? path]) async {
      final contents = await dbService.getFolderContents(folder.id);

      if (contents.isEmpty && path != null) {
        final directoryPath = '$path/';
        final directoryEntry = ArchiveFile(directoryPath, 0, [0]);
        archive.addFile(directoryEntry);
      }

      for (var item in contents) {
        if (item is Receipt) {
          final file = XFile('test/assets/${item.fileName}');
          final bytes = await File(file.path).readAsBytes();
          final archivePath = path != null ? '$path/${file.name}' : file.name;
          final archiveFile = ArchiveFile(archivePath, bytes.length, bytes);
          archive.addFile(archiveFile);
        } else if (item is Folder) {
          final newPath = path != null ? '$path/${item.name}' : item.name;
          await processFolder(item, newPath);
        }
      }
    }

    await processFolder(folder);

    if (archive.isEmpty) {
      return null;
    }

    final zipEncoder = ZipEncoder();

    final encodedArchive = zipEncoder.encode(archive);
    if (encodedArchive == null) {
      return null;
    }

    String tempZipFileFullPath =
        await FileService.tempZipFilePathGenerator(folder);
    final zipFile =
        await File(tempZipFileFullPath).writeAsBytes(encodedArchive);

    return zipFile;
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

  TestWidgetsFlutterBinding.ensureInitialized();
  databaseFactory = databaseFactoryFfi;

  final dbService = DatabaseService.instance;

  setUp(() async {
    // Delete all folders, receipts, and tags before each test
    await dbService.deleteAll();
  });

  tearDown(() async {
    // Delete all folders, receipts, and tags after each test
    await dbService.deleteAll();
  });

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

    test('generateFileName returns a valid file name', () {
      for (ImageFileType fileType in ImageFileType.values) {
        String fileName = FileService.generateFileName(fileType);
        String numsInFileName = fileName.split('_').last.split('.').first;
        expect(fileName, isNotNull);
        expect(fileName, isA<String>());
        // checks that the generated number in the file name is 4 characters long
        expect(numsInFileName, hasLength(5));
        // checks that each character in the generated file name is an integer
        numsInFileName.split('').forEach((element) => expect(int.parse(element), isA<int>() ));

        // Check the file extension based on the fileType
        switch (fileType) {
          case ImageFileType.png:
            expect(fileName, endsWith('.png'));
            break;
          case ImageFileType.heic:
            expect(fileName, endsWith('.heic'));
            break;
          case ImageFileType.jpg:
          case ImageFileType.jpeg:
            expect(fileName, endsWith('.jpg'));
            break;
        }
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
        File? compressedFile = await MockFileServiceCompress.compressFile(
            imageFile, localReceiptImagePath);
        expect(compressedFile, isNotNull);
        expect(await compressedFile!.length(),
            lessThanOrEqualTo(await imageFile.length()));
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

    test('tempZipFilePathGenerator returns a valid temporary zip file path',
        () async {
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

    test('shareReceipt', () {},
        skip: 'Unimplemented - manual testing required in the future');

    test('saveImageToCameraRoll', () {},
        skip: 'Unimplemented - manual testing required in the future');

    test(
        'shareFolderAsZip returns a zip file which preserves folder structure and files',
        () async {
      // create folder1 and insert into db
      final folder1Id = Utility.generateUid();
      final currentTimeStamp = Utility.getCurrentTime();
      final folder1 = Folder(
          id: folder1Id,
          name: 'testZipFolder',
          lastModified: currentTimeStamp,
          parentId: rootFolderId);
      await dbService.insertFolder(folder1);
      // create folder2 and insert into folder1 into db
      final folder2Id = Utility.generateUid();
      final folder2 = Folder(
          id: folder2Id,
          name: 'testSubFolder',
          lastModified: currentTimeStamp,
          parentId: folder1Id);
      await dbService.insertFolder(folder2);
      // create folder3 and insert into folder 2
      final folder3Id = Utility.generateUid();
      final folder3 = Folder(
          id: folder3Id,
          name: 'testSubSubFolder',
          lastModified: currentTimeStamp,
          parentId: folder3Id);
      await dbService.insertFolder(folder3);
      // create receipt from image1.png and insert into db in folder1
      final receipt1Id = Utility.generateUid();
      final receipt1 = Receipt(
          id: receipt1Id,
          name: 'testReceipt1',
          fileName: p.basename(imagePaths[0]),
          dateCreated: Utility.getCurrentTime(),
          lastModified: Utility.getCurrentTime(),
          storageSize: 100,
          parentId: folder1Id);
      await dbService.insertReceipt(receipt1);
      // create receipt from image2.jpeg and insert into db in folder2
      final receipt2Id = Utility.generateUid();
      final receipt2 = Receipt(
          id: receipt2Id,
          name: 'testReceipt2',
          fileName: p.basename(imagePaths[1]),
          dateCreated: Utility.getCurrentTime(),
          lastModified: Utility.getCurrentTime(),
          storageSize: 100,
          parentId: folder2Id);
      await dbService.insertReceipt(receipt2);
      // call test method
      final zipFile =
          await MockFileServiceShareFolderAsZip.shareFolderAsZip(folder1);
      // expect statements
      expect(zipFile, isNotNull);
      expect(zipFile, isA<File>());
      // unzip file
      final bytes = await zipFile!.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      // checking folder and file structure is preserved

      final receipt1Exists = archive.any((file) => file.name == 'image1.png');
      final receipt2Exists = archive.any((file) => file.name == 'testSubFolder/image2.jpeg');

      expect(receipt1Exists, isTrue);
      expect(receipt2Exists, isTrue);

      // cleaning up
      zipFile.delete();
      
    });
  });
}
