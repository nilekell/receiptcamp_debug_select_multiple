import 'package:flutter_test/flutter_test.dart';
import 'package:receiptcamp/data/utils/folder_helper.dart';

void main() {
  group('FolderHelper', () {
    test('validFolderName returns correct results', () {
      expect(FolderHelper.validFolderName('valid_folder-name'), isTrue);
      expect(FolderHelper.validFolderName('invalid folder name'), isTrue);
      expect(FolderHelper.validFolderName(''), isFalse);
      expect(FolderHelper.validFolderName('123'), isTrue);
      expect(FolderHelper.validFolderName('folder.name'), isFalse);
      expect(FolderHelper.validFolderName('folder/name'), isFalse);
      expect(FolderHelper.validFolderName('Folder*Name'), isFalse);
      expect(FolderHelper.validFolderName('Folder@123'), isFalse);
      expect(FolderHelper.validFolderName('Name&Folder'), isFalse);
      expect(FolderHelper.validFolderName('#Folder123'), isFalse);
      expect(FolderHelper.validFolderName('Folder!Name'), isFalse);
      expect(FolderHelper.validFolderName('Folder(Name)'), isFalse);
      expect(FolderHelper.validFolderName('Folder+Name'), isFalse);
      expect(FolderHelper.validFolderName('Folder:Name'), isFalse);
    });
  });
}