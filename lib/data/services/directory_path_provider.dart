import 'package:path_provider/path_provider.dart';

// This class is a singleton class responsible for managing
//  the application documents directory path. The purpose of this class is to
//  encapsulate and centralize the handling of the documents directory path to
//  ensure that it is consistently accessible throughout the application.
// This class is required as the application documents directory path changes between
// app updates so needs to be fetched whenever the app opens so it can be used to construct the
// Receipt class' localPath member
class DirectoryPathProvider {
  DirectoryPathProvider._privateConstructor();

  static final DirectoryPathProvider _instance =
      DirectoryPathProvider._privateConstructor();

  static DirectoryPathProvider get instance => _instance;

  // a private field that stores the application documents directory path.
  String _appDocDirPath = 'uninitialised path';
  
  // a private field that stores the temporary directory path
  String _tempDirPath = 'uninitialised path';

  // a public getter to access the application documents directory path.
  String get appDocDirPath => _appDocDirPath;
  
  // a public getter to access the temporary directory path.
  String get tempDirPath => _tempDirPath;

  // a method that asynchronously fetches and sets the application documents & temporary directory paths.
  Future<void> initialize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _appDocDirPath = dir.path;
      final tempDir = await getTemporaryDirectory();
      _tempDirPath = tempDir.path;

      print('DirectoryPathProvider initialised with appDocDirPath: $appDocDirPath');
      print('DirectoryPathProvider initialised with tempDirPath: $tempDirPath');
    } on Exception catch (e) {
      print("Error initializing appDocDirPath: $e");
      print('appDocDirPath: $appDocDirPath');
      print('_appDocDirPath: $_appDocDirPath');
      print('tempDirPath: $tempDirPath');
      print('_tempDirPath: $_tempDirPath');
      rethrow;
    }
  }
}
