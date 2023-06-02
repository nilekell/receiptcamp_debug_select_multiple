import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:uuid/uuid.dart';

class FolderHelper {
  // using DatabaseRepository singleton instance
  final DatabaseRepository databaseRepository = DatabaseRepository.instance;

  // method to check folder name is valid
  // This regex pattern assumes that the folder name should consist of only alphabetic
  // characters (lowercase or uppercase), digits, underscores, and hyphens.
  static bool validFolderName(String name) {
    final RegExp regex = RegExp(r'^[a-zA-Z0-9_-]+$');
    return name.isNotEmpty && regex.hasMatch(name);
}
  // method to create folder id
  static String generateUid() {
    // .v4() generates a random uid
    String folderUid = const Uuid().v4().toString();
    return folderUid;
  }
  
}