// ignore_for_file: unused_local_variable
import 'dart:io';
import 'package:path/path.dart';
import 'package:receiptcamp/data/services/directory_path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:receiptcamp/data/utils/receipt_helper.dart';

class SharingIntentService {
  // singleton
  SharingIntentService._privateConstructor();

  static final SharingIntentService _instance =
      SharingIntentService._privateConstructor();

  static SharingIntentService get instance => _instance;

  final RegExp imageFileExtensionRegExp =
      RegExp(r'\.(jpe?g|png)$', caseSensitive: false);

  // For sharing images coming from outside the app while the app is in the memory
  Stream<List<File>> get mediaStream {
    return ReceiveSharingIntent.getMediaStream().asyncMap(_mapSharedMediaFiles);
  }

  // For sharing images coming from outside the app while the app is closed
  Future<List<File>> get initialMedia {
    return ReceiveSharingIntent.getInitialMedia().then(_mapSharedMediaFiles);
  }

  Future<List<File>> _mapSharedMediaFiles(
      List<SharedMediaFile> sharedMediaFiles) async {

    print('sharedMediaFiles count: ${sharedMediaFiles.length}');
    List<File> sharedFiles = [];

    File tempImage;

    for (final file in sharedMediaFiles) {
      print('sharedMediaFile: ${file.path}');
      File sharedImage = File(file.path);
      String sharedImageExtension = extension(sharedImage.path);

      // skipping over and deleting images that aren't jpeg or png
      if (!imageFileExtensionRegExp.hasMatch(sharedImageExtension)) {
        print('discarded ${basename(sharedImage.path)}: image is not jpeg/png');
        sharedImage.delete();
        continue;
      }

      // skipping over and deleting images that don't pass receipt validation
      final (validImage as bool, invalidImageReason as ValidationError) =
          await ReceiptService.isValidImage(file.path);
      if (!validImage) {
        print('discarded ${basename(sharedImage.path)}: image failed validation - ${invalidImageReason.name}');
        sharedImage.delete();
        continue;
      }

      // copying images to temporary directory folder
      String newTempPath = '${DirectoryPathProvider.instance.tempDirPath}/${(basename(sharedImage.path).toLowerCase())}';
      tempImage = await sharedImage.copy(newTempPath);
      print('saving file: ${basename(tempImage.path)}');
      sharedFiles.add(tempImage);

      sharedImage.delete();
    }

    ReceiveSharingIntent.reset();

    return sharedFiles;
  }
}