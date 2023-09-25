import 'package:path_provider/path_provider.dart';

// This class is a singleton class responsible for managing
//  the application documents directory path. The purpose of this class is to
//  encapsulate and centralize the handling of the documents directory path to
//  ensure that it is consistently accessible throughout the application.
// This class is required as the application documents directory path changes between
// app updates so needs to be fetched whenever the app opens so it can be used to construct the
// Receipt class' localPath member
class DocumentDirectoryProvider {
  DocumentDirectoryProvider._privateConstructor();

  static final DocumentDirectoryProvider _instance =
      DocumentDirectoryProvider._privateConstructor();

  static DocumentDirectoryProvider get instance => _instance;

  // a private field that stores the application documents directory path.
  String _appDocDirPath = 'uninitialised path';

  // a public getter to access the `_appDocDirPath`.
  String get appDocDirPath => _appDocDirPath;

  // a method that asynchronously fetches and sets the application documents directory path.
  Future<void> initialize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _appDocDirPath = dir.path;
      print('DocumentDirectoryProvider initialised with appDocDirPath: $_appDocDirPath');
    } on Exception catch (e) {
      print("Error initializing appDocDirPath: $e");
      print('appDocDirPath: $appDocDirPath');
      rethrow;
    }
  }
}
