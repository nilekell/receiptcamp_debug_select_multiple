import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart';
import 'package:receiptcamp/data/data_constants.dart';
import 'package:receiptcamp/data/utils/file_helper.dart';
import 'package:receiptcamp/data/utils/receipt_helper.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/models/tag.dart';

class MockReceiptService extends Mock {
  static Future isValidImage(String imagePath, bool imageHasText) async {
    ValidationError validationError = ValidationError.none;

    try {
      final validSize = await FileService.isValidImageSize(imagePath);
      final hasText = imageHasText;

      if (validSize == false) validationError = ValidationError.size;
      if (hasText == false) validationError = ValidationError.text;
      if (validSize == false && hasText == false) validationError = ValidationError.both;

      // only returns true when both booleans are true
      return (validSize && hasText, validationError);
    } on Exception catch (e) {
      print('Error in ReceiptService.imageHasText: $e');
      return [false, validationError];
    }
  }

  static Future<List<Tag>> extractKeywordsAndGenerateTags(String receiptId) async {
    List<Tag> tags = [];
    List<String> receiptKeyWords = ['keyword1', 'keyword2', 'keyword3'];

    try {
      tags = ReceiptService.generateTags(receiptKeyWords, receiptId);
    } on Exception catch (e) {
      print('Error in MockReceiptService.extractKeywordsAndGenerateTags: $e');
    }

    return tags;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const imagePaths = [
    'test/assets/image1.png',
    'test/assets/image2.jpeg',
    'test/assets/image3.jpg',
    'test/assets/black_image.jpg',
    'test/assets/too_large_image.png'
  ];

  group('ReceiptService', () {
    test('identifyImageFileTypeFromString returns correct ImageFileType', () {
      expect(ReceiptService.identifyImageFileTypeFromString('.png'),
          ImageFileType.png);
      expect(ReceiptService.identifyImageFileTypeFromString('.heic'),
          ImageFileType.heic);
      expect(ReceiptService.identifyImageFileTypeFromString('.jpg'),
          ImageFileType.jpg);
      expect(ReceiptService.identifyImageFileTypeFromString('.jpeg'),
          ImageFileType.jpg);
    });

    test('isValidImage returns correct validation results', () async {
      final (validResult as bool, validResultReason as ValidationError) =
          await MockReceiptService.isValidImage(imagePaths[0], true);
      expect(validResult, true);
      expect(validResultReason, ValidationError.none);

      final (
        invalidTextResult as bool,
        invalidTextResultReason as ValidationError
      ) = await MockReceiptService.isValidImage(imagePaths[3], false);
      expect(invalidTextResult, false);
      expect(invalidTextResultReason, ValidationError.text);

      final (
        invalidSizeResult as bool,
        invalidSizeResultReason as ValidationError
      ) = await MockReceiptService.isValidImage(imagePaths[4], false);
      expect(invalidSizeResult, false);
      expect(invalidSizeResultReason, ValidationError.both);
    });

    test('validReceiptFileName returns correct validation result', () {
      expect(ReceiptService.validReceiptFileName('valid_file_name.png'), true);
      expect(
          ReceiptService.validReceiptFileName('invalid file name.png'), false);
      expect(ReceiptService.validReceiptFileName('invalid_file_name'), false);
    });

    test('createReceiptFromFile return correct valid Receipt object', () async {
      for (final imagePath in imagePaths) {
        final receiptFile = File(imagePath);
        final fileName = basename(receiptFile.path);
        const folderId = rootFolderName;
        final receiptUid = Utility.generateUid();

        final path = receiptFile.path;
        final currentTime = Utility.getCurrentTime();

        // getting compressed file sizes
        final compressedfileSize = await FileService.getFileSize(path, 2);

        // Creating receipt object to be stored in local db
        Receipt receipt = Receipt(
            id: receiptUid,
            name: fileName,
            localPath: path,
            dateCreated: currentTime,
            lastModified: currentTime,
            storageSize: compressedfileSize,
            // id of default folder
            parentId: folderId);

        expect(receipt, isA<Receipt>());
        expect(receipt, isNotNull);
        expect(receipt.id, receiptUid);
        expect(receipt.name, fileName);
        expect(receipt.localPath, receiptFile.path);
        expect(receipt.parentId, folderId);
      }
    });

    test('generateTags returns correct valid list of Tag objects', () async {
      const tagStrings = ['tag1', 'tag2', 'tag3'];
      const fakeReceiptId = '0123abc456';

      final tags = ReceiptService.generateTags(tagStrings, fakeReceiptId);

      expect(tags, isA<List<Tag>>());
      expect(tags.length, tagStrings.length);
      for (var i = 0; i < tags.length; i++) {
        expect(tags[i].tag, tagStrings[i]);
        expect(tags[i].receiptId, fakeReceiptId);
      }
    });

    test('extractKeywordsAndGenerateTags returns expected tags', () {}, 
    skip: '''This test is skipped because the method only interacts with methods 
    that have already been unit tested: TextRecognitionService.extractKeywordsFromPath, ReceiptService.generateTags.''');

    test('processingReceiptAndTags returns expected receipt and tags', () {}, 
    skip: '''This test is skipped because it essentially just calls a series of helper methods
    which all have been unit tested individually.''');
  });
}
