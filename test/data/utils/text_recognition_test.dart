import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:receiptcamp/data/utils/text_recognition.dart';

class MockTextRecognitionService extends Mock {
  static Future<List<String>> scanImageForText(List<String> scannedTextList) async {
    return scannedTextList;
  }

  static Future<List<String>> extractKeywordsFromPath(List<String> scannedTextList) async {
    return scannedTextList;
  }

  static Future<bool> imageHasText(List<String> scannedTextList) async {
    return scannedTextList.isNotEmpty && scannedTextList.length > 10;
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

  group('TextRecognitionService', () {
   test('loadCommonReceiptWords completes without errors', () async {
  await TextRecognitionService.loadCommonReceiptWords('en');
  expect(TextRecognitionService.loadCommonReceiptWords('en'), completes);
});

test('extractKeywords extracts keywords from scanned text', () async {
  final invalidScannedTextList = ['receipt', 'total', 'price', 'item'];
  final validScannedTextList = ['5378965', 'af3chv6', 'ethbyrgfe', 'A'];
  final inValidKeywords = await TextRecognitionService.extractKeywords(invalidScannedTextList);
  expect(inValidKeywords, isEmpty);
  final validKeywords = await TextRecognitionService.extractKeywords(validScannedTextList);
  expect(validKeywords, isNotEmpty);
});

test('scanImageForText returns expected types and is not null', () async {
      final result = await MockTextRecognitionService.scanImageForText(['test', 'data']);
      expect(result, isNotNull);
      expect(result, isA<List<String>>());
    });

    test('extractKeywordsFromPath returns expected types and is not null', () async {
      final result = await MockTextRecognitionService.extractKeywordsFromPath(['test', 'data']);
      expect(result, isNotNull);
      expect(result, isA<List<String>>());
    });

    test('imageHasText returns expected types and is not null', () async {
      final result = await MockTextRecognitionService.imageHasText(['test', 'data']);
      expect(result, isNotNull);
      expect(result, isA<bool>());
      expect(result, isFalse);

      final emptyResult = await MockTextRecognitionService.imageHasText([]);
      expect(emptyResult, isFalse);

      const validList = ['string1', 'string2', 'string3', 'string4', 'string5', 'string6', 'string7', 'string8', 'string9', 'string10', 'string11'];
      final validResult = await MockTextRecognitionService.imageHasText(validList);
      expect(validResult, isTrue);
    });
  });
}