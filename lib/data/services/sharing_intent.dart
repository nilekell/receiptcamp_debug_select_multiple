import 'dart:io';
import 'package:path/path.dart';
import 'package:receiptcamp/data/services/directory_path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class SharingIntentService {
  // singleton
  SharingIntentService._privateConstructor();

  static final SharingIntentService _instance =
      SharingIntentService._privateConstructor();

  static SharingIntentService get instance => _instance;

  final RegExp imageFileExtensionRegExp = RegExp(r'\.(jpe?g|png)$', caseSensitive: false);

  // For sharing images coming from outside the app while the app is in the memory
  Stream<List<File>> get mediaStream {
    print('get mediaStream');
    return ReceiveSharingIntent.getMediaStream().asyncMap(_mapSharedMediaFiles);
  }

  // For sharing images coming from outside the app while the app is closed
  Future<List<File>> get initialMedia {
    print('get initialMedia');
    return ReceiveSharingIntent.getInitialMedia().then(_mapSharedMediaFiles);
  }

  Future<List<File>> _mapSharedMediaFiles(List<SharedMediaFile> sharedMediaFiles) async {
    print('_mapSharedMediaFiles');
    List<File> sharedFiles = [];

    File tempImage;

    for (final file in sharedMediaFiles) {
      print('sharedMediaFile: ${file.path}');
      File sharedImage = File(file.path);
      String sharedImageExtension = extension(sharedImage.path);
      if (imageFileExtensionRegExp.hasMatch(sharedImageExtension)) {
        // copying images to temporary directory folder
        String newTempPath =
              '${DirectoryPathProvider.instance.tempDirPath}/${(basename(sharedImage.path).toLowerCase())}';
          tempImage = await sharedImage.copy(newTempPath);
          sharedImage.delete();
          print('saving file: ${basename(tempImage.path)}');
          // deleting files in share extension folder
          sharedFiles.add(tempImage);
      } else {
        // skipping over images that aren't jpeg or png
        continue;
      }
    }

    ReceiveSharingIntent.reset();

    return sharedFiles;
  }

}