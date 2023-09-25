import 'package:flutter_test/flutter_test.dart';
import 'package:receiptcamp/data/data_constants.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/models/tag.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:receiptcamp/data/services/database.dart';

void main() {
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

    group('ReceiptMethods', () {
      test('insertReceipt', () async {
        final receiptId = Utility.generateUid();
        final receipt = Receipt(
            id: receiptId,
            name: 'testReceipt',
            fileName: 'testName',
            dateCreated: Utility.getCurrentTime(),
            lastModified: Utility.getCurrentTime(),
            storageSize: 100,
            parentId: rootFolderId);
        await dbService.insertReceipt(receipt);
        final result = await dbService.getReceiptById(receiptId);
        expect(result.id, receiptId);
        expect(result.name, 'testReceipt');
      });

      test('getReceiptById', () async {
        final receiptId = Utility.generateUid();
        final receipt = Receipt(
            id: receiptId,
            name: 'testReceiptById',
            fileName: 'testName',
            dateCreated: Utility.getCurrentTime(),
            lastModified: Utility.getCurrentTime(),
            storageSize: 100,
            parentId: rootFolderId);
        await dbService.insertReceipt(receipt);
        final result = await dbService.getReceiptById(receiptId);
        expect(result.id, receiptId);
        expect(result.name, 'testReceiptById');
      });

      test('getReceipts', () async {
        // create some receipts
        final receipt1Id = Utility.generateUid();
        final receipt2Id = Utility.generateUid();

        await dbService.insertReceipt(Receipt(
            id: receipt1Id,
            name: 'receipt1',
            fileName: 'testName1',
            dateCreated: Utility.getCurrentTime(),
            lastModified: Utility.getCurrentTime(),
            storageSize: 100,
            parentId: rootFolderId));
        await dbService.insertReceipt(Receipt(
            id: receipt2Id,
            name: 'receipt2',
            fileName: 'testName2',
            dateCreated: Utility.getCurrentTime(),
            lastModified: Utility.getCurrentTime(),
            storageSize: 100,
            parentId: rootFolderId));

        // get the list of receipts
        final result = await dbService.getReceipts();

        // check the returned list of receipt ids against the previously created list of receipt ids
        final returnedIds = result.map((receipt) => receipt.id);
        expect(returnedIds, containsAll([receipt1Id, receipt2Id]));
        expect(returnedIds.length, 2);
      });

      test('updateReceipt', () async {
        final receiptId = Utility.generateUid();
        final receiptDateCreated = Utility.getCurrentTime();
        final receipt = Receipt(
            id: receiptId,
            name: 'testReceipt',
            fileName: 'testName',
            dateCreated: receiptDateCreated,
            lastModified: receiptDateCreated,
            storageSize: 100,
            parentId: rootFolderId);
        await dbService.insertReceipt(receipt);
        final changedReceiptLastModified = Utility.getCurrentTime();
        final changedReceipt = Receipt(
            id: receiptId,
            name: 'updatedReceipt',
            fileName: 'testName',
            dateCreated: receiptDateCreated,
            lastModified: changedReceiptLastModified,
            storageSize: 100,
            parentId: rootFolderId);
        await dbService.updateReceipt(changedReceipt);
        final updatedReceipt = await dbService.getReceiptById(receiptId);

        expect(updatedReceipt.id, receiptId);
        expect(updatedReceipt.name, 'updatedReceipt');
        expect(updatedReceipt.dateCreated, receiptDateCreated);
        expect(updatedReceipt.fileName, 'testName');
        expect(updatedReceipt.lastModified, changedReceiptLastModified);
        expect(updatedReceipt.storageSize, 100);
        expect(updatedReceipt.parentId, rootFolderId);
      });

      test('deleteReceipt', () async {
        final receiptId = Utility.generateUid();
        final receipt = Receipt(
            id: receiptId,
            name: 'testReceipt',
            fileName: 'testName',
            dateCreated: Utility.getCurrentTime(),
            lastModified: Utility.getCurrentTime(),
            storageSize: 100,
            parentId: rootFolderId);
        await dbService.insertReceipt(receipt);
        await dbService.deleteReceipt(receiptId);
        try {
          await dbService.getReceiptById(receiptId);
        } catch (e) {
          expect(e, isA<Exception>());
        }
      });

      test('moveReceipt', () async {
        final targetFolderId = Utility.generateUid();
        final targetFolder = Folder(
            id: targetFolderId,
            name: 'targetFolder',
            lastModified: Utility.getCurrentTime(),
            parentId: rootFolderId);
        await dbService.insertFolder(targetFolder);
        final receiptId = Utility.generateUid();
        final receipt = Receipt(
            id: receiptId,
            name: 'testMoveReceipt',
            fileName: 'testName',
            dateCreated: Utility.getCurrentTime(),
            lastModified: Utility.getCurrentTime(),
            storageSize: 100,
            parentId: rootFolderId);
        await dbService.insertReceipt(receipt);
        await dbService.moveReceipt(receipt, targetFolderId);
        final movedReceipt = await dbService.getReceiptById(receiptId);
        expect(movedReceipt.parentId, targetFolderId);
      });

      test('renameReceipt', () async {
        // Create a new receipt
        final receiptId = Utility.generateUid();
        final receipt = Receipt(
            id: receiptId,
            name: 'testRenameReceipt',
            fileName: 'testName',
            dateCreated: Utility.getCurrentTime(),
            lastModified: Utility.getCurrentTime(),
            storageSize: 100,
            parentId: rootFolderId);

        // Insert the receipt into the database
        await dbService.insertReceipt(receipt);

        // Rename the receipt
        await dbService.renameReceipt(receipt.id, 'newName');

        // Retrieve the receipt from the database
        final renamedReceipt = await dbService.getReceiptById(receipt.id);

        // Check if the receipt's name has been updated
        expect(renamedReceipt.name, 'newName');
      });

      test('getRecentReceipts', () async {
        // Create 10 receipts
        for (int i = 0; i < 10; i++) {
          final receipt = Receipt(
            id: 'testId$i',
            name: 'testName$i',
            fileName: 'testName$i',
            dateCreated: i < 8
                ? Utility.getCurrentTime()
                : 1000, // set old timestamp for last two receipts
            lastModified: i < 8
                ? Utility.getCurrentTime()
                : 1000, // set old timestamp for last two receipts
            storageSize: 100,
            parentId: 'testParentId',
          );

          // Insert the receipt into the database
          await dbService.insertReceipt(receipt);
        }

        // Retrieve the 8 most recently created receipts
        final recentReceipts = await dbService.getRecentReceipts();

        // Check if the correct number of receipts has been retrieved
        expect(recentReceipts.length, 8);

        // Check if the retrieved receipts are in the correct order
        for (int i = 0; i < 8; i++) {
          expect(recentReceipts[i].name, 'testName$i');
        }

        // Check if the retrieved receipts do not contain the two receipts with the old timestamps
        for (var receipt in recentReceipts) {
          expect(receipt.dateCreated, isNot(1000));
          expect(receipt.lastModified, isNot(1000));
        }
      });

      test('getReceiptByName', () async {
        final receiptId = Utility.generateUid();
        final receipt = Receipt(
            id: receiptId,
            name: 'testGetByNameReceipt',
            fileName: 'testName',
            dateCreated: Utility.getCurrentTime(),
            lastModified: Utility.getCurrentTime(),
            storageSize: 100,
            parentId: rootFolderId);

        // Insert the receipt into the database
        await dbService.insertReceipt(receipt);

        // Retrieve the receipt by its name
        final retrievedReceipts =
            await dbService.getReceiptByName(receipt.name);

        // Check if the correct receipt has been retrieved
        expect(retrievedReceipts[0].id, receipt.id);
      });
    });

    group('TagMethods', () {
      test('insertTags', () async {
        // creating mock receipt
        final receiptId = Utility.generateUid();
        final receiptDateCreated = Utility.getCurrentTime();
        await dbService.insertReceipt(Receipt(
            id: receiptId,
            name: 'testTagReceipt',
            fileName: 'testName',
            dateCreated: receiptDateCreated,
            lastModified: receiptDateCreated,
            storageSize: 100,
            parentId: rootFolderId));

        // creating mock tag
        final tagId = Utility.generateUid();
        final tag = Tag(id: tagId, receiptId: receiptId, tag: 'testTag');

        // Insert the tag into the database
        await dbService.insertTags([tag]);

        // Retrieve the tag by its receiptId
        final retrievedTags = await dbService.getTagsByReceiptID(receiptId);

        // Check if the correct tag has been inserted
        expect(retrievedTags[0].id, tag.id);
      });

      test('getTagsByReceiptID', () async {
        // creating mock receipt
        final receiptId = Utility.generateUid();
        final receiptDateCreated = Utility.getCurrentTime();
        await dbService.insertReceipt(Receipt(
            id: receiptId,
            name: 'testTagReceipt',
            fileName: 'testName',
            dateCreated: receiptDateCreated,
            lastModified: receiptDateCreated,
            storageSize: 100,
            parentId: rootFolderId));

        final tagId = Utility.generateUid();
        final tag = Tag(id: tagId, receiptId: receiptId, tag: 'testTag');

        // Insert the tag into the database
        await dbService.insertTags([tag]);

        // Retrieve the tag by its receiptId
        final retrievedTags = await dbService.getTagsByReceiptID(receiptId);

        // Check if the correct tag has been retrieved
        expect(retrievedTags[0].id, tag.id);
      });

      test('deleteTagsForAReceipt', () async {
        // creating mock receipt
        final receiptId = Utility.generateUid();
        final receiptDateCreated = Utility.getCurrentTime();
        await dbService.insertReceipt(Receipt(
            id: receiptId,
            name: 'testTagReceipt',
            fileName: 'testName',
            dateCreated: receiptDateCreated,
            lastModified: receiptDateCreated,
            storageSize: 100,
            parentId: rootFolderId));

        final tagId = Utility.generateUid();
        final tag = Tag(id: tagId, receiptId: receiptId, tag: 'testTag');

        // Insert the tag into the database
        await dbService.insertTags([tag]);

        // Delete the tag for the receipt
        await dbService.deleteTagsForAReceipt(receiptId);

        // Try to retrieve the tag by its receiptId
        final retrievedTags = await dbService.getTagsByReceiptID(receiptId);

        // Check if the tag has been deleted
        expect(retrievedTags.isEmpty, true);
      });

      test('getSuggestedReceiptsByTags', () async {
        // Insert some receipts and tags
        final receiptId1 = Utility.generateUid();
        final receiptId2 = Utility.generateUid();
        final tag1 = Tag(
            id: Utility.generateUid(), receiptId: receiptId1, tag: 'testTag1');
        final tag2 = Tag(
            id: Utility.generateUid(), receiptId: receiptId2, tag: 'testTag2');
        await dbService.insertReceipt(Receipt(
            id: receiptId1,
            name: 'testReceipt1',
            fileName: 'testName1',
            dateCreated: Utility.getCurrentTime(),
            lastModified: Utility.getCurrentTime(),
            storageSize: 100,
            parentId: rootFolderId));
        await dbService.insertReceipt(Receipt(
            id: receiptId2,
            name: 'testReceipt2',
            fileName: 'testName2',
            dateCreated: Utility.getCurrentTime(),
            lastModified: Utility.getCurrentTime(),
            storageSize: 100,
            parentId: rootFolderId));
        await dbService.insertTags([tag1, tag2]);

        // Get suggested receipts by tags
        final suggestedReceipts =
            await dbService.getSuggestedReceiptsByTags('testTag1');

        // Check if the correct receipts are retrieved
        expect(suggestedReceipts.length, 1);
        expect(suggestedReceipts[0].id, receiptId1);
      });

      test('getFinalReceiptsByTags', () async {
        // Insert some receipts and tags
        final receiptId1 = Utility.generateUid();
        final receiptId2 = Utility.generateUid();
        final tag1 = Tag(
            id: Utility.generateUid(), receiptId: receiptId1, tag: 'testTag1');
        final tag2 = Tag(
            id: Utility.generateUid(), receiptId: receiptId2, tag: 'testTag2');
        await dbService.insertReceipt(Receipt(
            id: receiptId1,
            name: 'testReceipt1',
            fileName: 'testName1',
            dateCreated: Utility.getCurrentTime(),
            lastModified: Utility.getCurrentTime(),
            storageSize: 100,
            parentId: rootFolderId));
        await dbService.insertReceipt(Receipt(
            id: receiptId2,
            name: 'testReceipt2',
            fileName: 'testName2',
            dateCreated: Utility.getCurrentTime(),
            lastModified: Utility.getCurrentTime(),
            storageSize: 100,
            parentId: rootFolderId));
        await dbService.insertTags([tag1, tag2]);

        // Get final receipts by tags
        final finalReceipts =
            await dbService.getFinalReceiptsByTags('testTag2');

        // Check if the correct receipts are retrieved
        expect(finalReceipts.length, 1);
        expect(finalReceipts[0].id, receiptId2);
      });
    });
  });
}
