import 'package:receiptcamp/data/repositories/database_repository.dart';

class FolderHelper {
  // using DatabaseRepository singleton instance
  final DatabaseRepository databaseRepository = DatabaseRepository.instance;

  // method to check folder name is valid
  // This regex pattern assumes that the folder name should consist of only alphabetic
  // characters (lowercase or uppercase), digits, underscores, and hyphens.
  static bool validFolderName(String name) {
    try {
      final RegExp regex = RegExp(r'^[a-zA-Z0-9_-]+$');
      return name.isNotEmpty && regex.hasMatch(name);
    } on Exception catch (e) {
      print('Error in validFolderName: $e');
      return false;
    }
  }
}
