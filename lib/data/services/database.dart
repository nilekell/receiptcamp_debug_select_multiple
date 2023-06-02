import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/models/tag.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  // defining a static instance of the DBHelper class, allowing us to
  // access the same db instance from anywhere in the program
  static final DatabaseService instance = DatabaseService._getInstance();
  // Define a private static variable to hold our database instance.
  static Database? _database;
  // Define a private constructor to prevent the class from being instantiated
  // from outside of the class.
  DatabaseService._getInstance();

  // Define a getter that returns our database instance. If the database
  // instance doesn't exist yet, we create it.
  Future<Database> get database async {
    if (_database != null) {
      // print('acessing database...');
      return _database!;
    } 
    _database = await _initDatabase();
    return _database!;
  }

  // Define a private method to initialize our database.
  Future<Database> _initDatabase() async {
    // Get the path to the directory where we can store our database.
    final dbPath = await getDatabasesPath();
    // Create the path in the available directory to store our database.
    final path = '$dbPath/receipts.db';

    return await openDatabase(
      // creating database found at new path
      path,
      version: 1,
      // Create receipt table
      onCreate: (db, version) async {
        // create receipts table
        await db.execute('''
          CREATE TABLE receipts (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            localPath TEXT NOT NULL,
            dateCreated INTEGER NOT NULL,
            lastModified INTEGER NOT NULL,
            storageSize INTEGER NOT NULL,
            parentId TEXT NOT NULL
            FOREIGN KEY (parentId) REFERENCES folders(id)       
          )
        ''');

        // create tags table
        await db.execute('''
          CREATE TABLE tags (
              id TEXT PRIMARY KEY,
              receiptId TEXT NOT NULL,
              tag TEXT NOT NULL, 
              FOREIGN KEY (receiptId) REFERENCES receipts(id)
          )
      ''');

      // Add Folder table creation
      await db.execute('''
        CREATE TABLE folders (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          parentId TEXT NOT NULL,
          FOREIGN KEY (parentId) REFERENCES receipts(id)
        )
      ''');

      // creating an initial folder for all receipts to first be added to when they are created
      await db.execute('''
        INSERT INTO folders (id,name,parentId)
        VALUES('a1','all','null')
      ''');
      },
    );

    
  }

  // Add Folder operations

  // Method to insert a Folder object into the database.
  Future<void> insertFolder(Folder folder) async {
    final db = await database;
    if (folder.name == 'all') {
      throw Exception('folder cannot have same name as default folder');
      // function ends after throw statement
    }
    await db.insert('folders', folder.toMap());
  }

  // Method to get all Folder objects from the database.
  Future<List<Folder>> getFolders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('folders');
    return List.generate(maps.length, (i) {
      return Folder(
        id: maps[i]['id'],
        name: maps[i]['name'],
        parentId: maps[i]['parentId'],
      );
    });
  }

  // Method to delete a Folder object from the database based on its id.
  Future<int> deleteFolder(String id) async {
    final db = await database;
    return await db.delete(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // method to check if folder already exists
  Future<bool> folderExists(String id, String name) async {
    final db = await database;
    final countResult = await db.rawQuery('''
      SELECT COUNT (*)
      FROM folders
      WHERE id=? or name=? 
      ''',
      [id, name]);

    int? numSameFolders = Sqflite.firstIntValue(countResult);

      if (numSameFolders != 0) {
        return true;
      } else {
        return false;
      }
  }

  // Add Receipt operations

  // Method to insert a Receipt object into the database.
  Future<int> insertReceipt(Receipt receipt) async {
    final db = await database;
    return await db.insert('receipts', receipt.toMap());
  }

  // Method to update a Receipt object in the database.
  Future<int> updateReceipt(Receipt receipt) async {
    final db = await database;
    return await db.update(
      'receipts',
      receipt.toMap(),
      where: 'id = ?',
      whereArgs: [receipt.id],
    );
  }

  // Method to delete a Receipt object from the database based on its id.
  Future<int> deleteReceipt(String id) async {
    final db = await database;
    return await db.delete(
      'receipts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Method to get all Receipt objects from the database.
  Future<List<Receipt>> getReceipts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('receipts');
    return List.generate(maps.length, (i) {
      return Receipt(
          id: maps[i]['id'],
          name: maps[i]['name'],
          localPath: maps[i]['localPath'],
          dateCreated: maps[i]['dateCreated'], 
          lastModified: maps[i]['lastModified'], 
          storageSize: maps[i]['storageSize'],
          parentId: maps[i]['parentId']
);
    });
  }

  // Method to print all receipts objects from database
  Future<void> printAllReceipts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('receipts');
    print('num of receipts: ${maps.length}');
    print('All receipts in database:');
    maps.forEach((receiptMap) {
      final receipt = Receipt(
        id: receiptMap['id'],
        name: receiptMap['name'],
        localPath: receiptMap['localPath'],
        dateCreated: receiptMap['dateCreated'], 
        lastModified: receiptMap['lastModified'], 
        storageSize: receiptMap['storageSize'],
        parentId: receiptMap['parentId']
      );

      print('id: ${receipt.id.toString()}');
      print('name: ${receipt.name.toString()}');
      print('localPath: ${receipt.localPath.toString()}');
      print('dateCreated: ${receipt.dateCreated.toString()}');
      print('dateCreated: ${receipt.dateCreated.toString()}');
      print('lastModified: ${receipt.lastModified.toString()}');
      print('storageSize: ${receipt.storageSize.toString()}');
      print('//--------------//');
    });
  }

  // Method to get Receipt objects by name from the database
  Future<List<Receipt>> getReceiptByName(String name) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('receipts',
        // retrieving the following columns from the database
        columns: ['id', 'userID', 'name', 'localPath','dateCreated'],
        // '?'s are replaced with the items in the [whereArgs] field
        where: 'name = ?',
        // [name] is the argument of the function
        whereArgs: [name]);
    return List.generate(maps.length, (i) {
      return Receipt(
          id: maps[i]['id'],
          name: maps[i]['name'],
          localPath: maps[i]['localPath'],
          dateCreated: maps[i]['dateCreated'], 
          lastModified: maps[i]['lastModified'], 
          storageSize: maps[i]['storageSize'],
          parentId: maps[i]['parentId']);
    });
  }

  // Method to get recently created receipts from database
  Future<List<Receipt>> getRecentReceipts() async {
    final db = await database;
    // Query the database for the 8 most recently created receipts
    final List<Map<String, dynamic>> maps = await db
        .rawQuery('SELECT * FROM receipts ORDER BY dateCreated DESC LIMIT 8');
    // Convert the List<Map<String, dynamic>> to a List<Receipt>
    List<Receipt> receipts = List.generate(maps.length, (i) {
      return Receipt(
          id: maps[i]['id'],
          name: maps[i]['name'],
          localPath: maps[i]['localPath'],
          dateCreated: maps[i]['dateCreated'], 
          lastModified: maps[i]['lastModified'], 
          storageSize: maps[i]['storageSize'],
          parentId: maps[i]['parentId']);
    });

    return receipts;
  }

  Future<void> deleteAll() async {
    final db = await database;
    // delete() returns number (int) of rows deleted
    // deleting all rows in the receipts table NOT SPECIFIC TO USER 
    print(await db.delete('receipts'));
    // deleting ALL tags in database NOT SPECIFIC TO USER 
    print(await db.delete('tags'));
    // deleting all folders in database NOT SPECIFIC TO USER
    print(await db.delete('folders'));
  }

  // method to insert a receipt tag into tags table in the database
  Future<int> insertTag(Tag tag) async {
    final db = await database;
    // returns id of last tag inserted into db by the query
    return await db.insert('tags', tag.toMap());
  }

  // Add Tag operations

  // method to get all tags associated with a receipt based on its id
  Future<List<Tag>> getTagsByReceiptID(String receiptId) async {
    final db = await database;
    // retrieving a list of maps where each map represents a Tag object
    final List<Map<String, dynamic>> tagMaps = await db
        .rawQuery('''
                  SELECT *
                  FROM tags 
                  WHERE receiptId=?
                  ''',
        [receiptId]);
    // returning a list of Tag objects
    return List.generate(tagMaps.length, (i) {
      return Tag(
        id: tagMaps[i]['id'],
        receiptId: tagMaps[i]['receiptId'],
        tag: tagMaps[i]['tag']
      );
    });
  }

  // method to delete all receipt tags associated with a single receipt
  Future<int> deleteTagsForAReceipt(String receiptId) async {
    final db = await database;
    return await db.delete(
      'tags',
      where: 'receiptId = ?',
      whereArgs: [receiptId],
    );
  }

  // method to get first 8 receipts from specific tags, ordering by most recent
  Future<List<Receipt>> getSuggestedReceiptsByTags(String tag) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db
        // query will return receipts that have tags that match any part of the user's search query
        .rawQuery('''
        SELECT receipts.id, receipts.name, receipts.localPath, receipts.dateCreated, receipts.lastModified, receipts.storageSize, receipts.parentId
        FROM receipts
        INNER JOIN tags ON receipts.id = tags.receiptId
        WHERE tags.tag LIKE '%' || ? || '%'
        GROUP BY receipts.id
        ORDER BY dateCreated DESC
        LIMIT 8
        ''',
        [tag]);

    final receiptList =  List.generate(maps.length, (i) {
      return Receipt(
          id: maps[i]['id'],
          name: maps[i]['name'],
          localPath: maps[i]['localPath'],
          dateCreated: maps[i]['dateCreated'], 
          lastModified: maps[i]['lastModified'], 
          storageSize: maps[i]['storageSize'],
          parentId: maps[i]['parentId']
);
    });

    print(receiptList.length);
    return receiptList;
  }

  // method to get all receipts from specific tags, ordering by most recent
  Future<List<Receipt>> getFinalReceiptsByTags(String tag) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db
        // the LIKE operator is used to match any tag that contains the specific string
        // the '%' is a wildcard that matches any sequence of characters before or after the specifed string
        // the '||' is a operator used to concatenate the '%' and '?' to form the full search pattern
        .rawQuery('''
        SELECT receipts.id, receipts.name, receipts.localPath, receipts.dateCreated, receipts.lastModified, receipts.storageSize, receipts.parentId
        FROM receipts
        INNER JOIN tags ON receipts.id = tags.receiptId
        WHERE tags.tag LIKE '%' || ? || '%'
        GROUP BY receipts.id
        ORDER BY dateCreated DESC
        ''',
        [tag]);

    final receiptList = List.generate(maps.length, (i) {
      return Receipt(
          id: maps[i]['id'],
          name: maps[i]['name'],
          localPath: maps[i]['localPath'],
          dateCreated: maps[i]['dateCreated'], 
          lastModified: maps[i]['lastModified'], 
          storageSize: maps[i]['storageSize'],
          parentId: maps[i]['parentId']
);
    });
    
    print('num of receipts: ${receiptList.length}');
    return receiptList;
  }
}
