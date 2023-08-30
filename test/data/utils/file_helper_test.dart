import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receiptcamp/data/utils/file_helper.dart';
import 'package:receiptcamp/data/utils/utilities.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('FileHelper', () {

    test('getFileSize returns correct file size', () async {
      final imagePaths = [
        'test/assets/image1.png',
        'test/assets/image2.jpeg',
        'test/assets/image3.jpg'
      ];

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

    test('getLocalImagePath returns correct local image path', () async {
      // iterate over ImageFileType.values
      for (final imageFileType in ImageFileType.values) {
        final expectedImagePath = '${(await getApplicationDocumentsDirectory()).path}/${Utility.generateFileName(imageFileType)}';
        final actualImagePath = await FileService.getLocalImagePath(imageFileType);
        expect(actualImagePath, equals(expectedImagePath));
      }

    });
  });
}
