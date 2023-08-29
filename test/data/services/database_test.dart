import 'package:flutter_test/flutter_test.dart';
import 'package:receiptcamp/data/data_constants.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:receiptcamp/data/services/database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  databaseFactory = databaseFactoryFfi;

  final dbService = DatabaseService.instance;

  group('DatabaseService', () {
    group('Initialisation', () {
      test('should be a singleton', () async {
        final db1 = DatabaseService.instance;
        final db2 = DatabaseService.instance;
        expect(db1, db2);
      });

      test('should return a database instance', () async {
        final db = await dbService.database;
        expect(db, isNotNull);
        expect(db.isOpen, true);
      });

      test('should create the necessary tables', () async {
        final db = await dbService.database;

        final folderTableExists = Sqflite.firstIntValue(await db.rawQuery('''
          SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = 'folders';
        ''')) == 1;

        final receiptsTableExists = Sqflite.firstIntValue(await db.rawQuery('''
          SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = 'receipts';
        ''')) == 1;

        final tagsTableExists = Sqflite.firstIntValue(await db.rawQuery('''
          SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = 'tags';
        ''')) == 1;

        expect(folderTableExists, true);
        expect(receiptsTableExists, true);
        expect(tagsTableExists, true);
      });

      test('should create a root folder', () async {
        final db = await dbService.database;

        final rootFolderExists = Sqflite.firstIntValue(await db.rawQuery('''
          SELECT COUNT(*) FROM folders WHERE id = ?;
        ''', [rootFolderId])) == 1;

        expect(rootFolderExists, true);
      });
    });

    group('FolderMethods', () {
      test('insertFolder', () async {
        final insertionFolderId = Utility.generateUid();
        final currentTimeStamp = Utility.getCurrentTime();
        final folder = Folder(
            id: insertionFolderId,
            name: 'testInsertionFolder',
            lastModified: currentTimeStamp,
            parentId: rootFolderId);
        await dbService.insertFolder(folder);
        final result = await dbService.getFolderById(insertionFolderId);
        expect(result.id, insertionFolderId);
        expect(result.name, 'testInsertionFolder');
      });

      test('getFolderById', () async {
        final getFolderId = Utility.generateUid();
        final currentTimeStamp = Utility.getCurrentTime();
        final folder = Folder(
            id: getFolderId,
            name: 'testGetFolder',
            lastModified: currentTimeStamp,
            parentId: rootFolderId);
        await dbService.insertFolder(folder);
        final result = await dbService.getFolderById(getFolderId);
        expect(result.id, getFolderId);
        expect(result.name, 'testGetFolder');
      });

      test('getFolders', () async {
        final result = await dbService.getFolders();
        expect(result, isA<List<Folder>>());
        expect(result.first, isA<Folder>());
      });

      test('moveFolder', () async {
        final folderToBeMovedId = Utility.generateUid();
        final targetFolderId = Utility.generateUid();
        await dbService.insertFolder(Folder(
            id: folderToBeMovedId,
            name: 'testFolderToBeMoved',
            lastModified: Utility.getCurrentTime(),
            parentId: rootFolderId));
        await dbService.insertFolder(Folder(
            id: targetFolderId,
            name: 'testTargetFolder',
            lastModified: Utility.getCurrentTime(),
            parentId: rootFolderId));
        final folder = await dbService.getFolderById(folderToBeMovedId);
        await dbService.moveFolder(folder, targetFolderId);

        final updatedFolder = await dbService.getFolderById(folderToBeMovedId);
        expect(updatedFolder.parentId, targetFolderId);
      });

      test('getFoldersThatCanBeMovedTo', () async {
        // delete all folders except the root folder
        await dbService.deleteAllFoldersExceptRoot();

        // create some folders and a nested folder
        final folder1Id = Utility.generateUid();
        final folder2Id = Utility.generateUid();
        final parentOfFolderToBeMovedId = Utility.generateUid();
        final folderToBeMovedId = Utility.generateUid();

        await dbService.insertFolder(Folder(
            id: folder1Id,
            name: 'folder1',
            lastModified: Utility.getCurrentTime(),
            parentId: rootFolderId));
        await dbService.insertFolder(Folder(
            id: folder2Id,
            name: 'folder2',
            lastModified: Utility.getCurrentTime(),
            parentId: rootFolderId));
        await dbService.insertFolder(Folder(
            id: parentOfFolderToBeMovedId,
            name: 'parentFolder',
            lastModified: Utility.getCurrentTime(),
            parentId: rootFolderId));
        await dbService.insertFolder(Folder(
            id: folderToBeMovedId,
            name: 'nestedFolder',
            lastModified: Utility.getCurrentTime(),
            parentId: parentOfFolderToBeMovedId));

        // create a list of folder ids that the nested folder can be moved to
        final validMoveToFolderIds = [folder1Id, folder2Id];

        // get the list of folder ids that the nested folder can be moved to
        final result = await dbService.getFoldersThatCanBeMovedTo(
            folderToBeMovedId, parentOfFolderToBeMovedId);

        // check the returned list of folder ids against the previously created list of folder ids
        final returnedIds = result.map((folder) => folder.id);
        expect(returnedIds, containsAll(validMoveToFolderIds));
      });

      test('getRecursiveSubFolderIds', () async {
        // create some folders and subfolders
        final folder1Id = Utility.generateUid();
        final subFolder1Id = Utility.generateUid();
        final subSubFolder1Id = Utility.generateUid();

        await dbService.insertFolder(Folder(
            id: folder1Id,
            name: 'testFolder1',
            lastModified: Utility.getCurrentTime(),
            parentId: rootFolderId));
        await dbService.insertFolder(Folder(
            id: subFolder1Id,
            name: 'subFolder1',
            lastModified: Utility.getCurrentTime(),
            parentId: folder1Id));
        await dbService.insertFolder(Folder(
            id: subSubFolder1Id,
            name: 'subSubFolder1',
            lastModified: Utility.getCurrentTime(),
            parentId: subFolder1Id));

        // get recursive sub folder ids
        final result = await dbService.getRecursiveSubFolderIds(folder1Id);

        // check if all subfolders ids are retrieved
        expect(result, containsAllInOrder([subFolder1Id, subSubFolder1Id]));
      });

      test('deleteFolder', () async {
        final deleteFolderId = Utility.generateUid();
        await dbService.insertFolder(Folder(
            id: deleteFolderId,
            name: 'testDeleteFolder',
            lastModified: Utility.getCurrentTime(),
            parentId: rootFolderId));
        await dbService.deleteFolder(deleteFolderId);
        try {
          await dbService.getFolderById(deleteFolderId);
        } catch (e) {
          expect(e, isA<Exception>());
        }
      });

      test('folderExists', () async {
        final result = await dbService.folderExists(id: rootFolderId);
        expect(result, true);
      });

      test('deleteAllFoldersExceptRoot', () async {
        final folder1Id = Utility.generateUid();
        final folder2Id = Utility.generateUid();

        // Insert a couple of folders into the database
        await dbService.insertFolder(Folder(
            id: folder1Id,
            name: 'testFolder1',
            lastModified: Utility.getCurrentTime(),
            parentId: rootFolderId));
        await dbService.insertFolder(Folder(
            id: folder2Id,
            name: 'testFolder2',
            lastModified: Utility.getCurrentTime(),
            parentId: rootFolderId));

        // Delete all folders except the root folder
        await dbService.deleteAllFoldersExceptRoot();

        // Query the database for all folders
        final result = await dbService.getFolders();

        // Check if the result is a List of Folder objects
        expect(result, isA<List<Folder>>());

        // Check if the only folder in the database is the root folder
        final folderIds = result.map((folder) => folder.id).toList();
        expect(folderIds, [rootFolderId]);
      });
    });

    group('ReceiptMethods', () {});
  });
}
