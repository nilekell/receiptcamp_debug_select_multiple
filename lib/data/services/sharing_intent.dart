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

    // print('sharedMediaFiles count: ${sharedMediaFiles.length}');
    List<File> sharedFiles = [];

    if (await _sharedFileIsZipFile(sharedMediaFiles)) {
      final File zipFile = await _processZipMediaFile(sharedMediaFiles[0]);
      sharedFiles = List.from([zipFile]);
      ReceiveSharingIntent.reset();
      return sharedFiles;
    }

    File tempImage;

    ValidationError invalidImageReason = ValidationError.none;

    for (final file in sharedMediaFiles) {
      // print('sharedMediaFile: ${file.path}');
      File sharedImage = File(file.path);
      String sharedImageExtension = extension(sharedImage.path);

      // skipping over and deleting images that aren't jpeg or png
      if (!imageFileExtensionRegExp.hasMatch(sharedImageExtension)) {
        // print('discarded ${basename(sharedImage.path)}: image is not jpeg/png');
        sharedImage.delete();
        continue;
      }

      // skipping over and deleting images that don't pass receipt validation
      bool validImage;
      (validImage, invalidImageReason) =
          await ReceiptService.isValidImage(file.path);
      if (!validImage) {
        // print('discarded ${basename(sharedImage.path)}: image failed validation - ${invalidImageReason.name}');
        sharedImage.delete();
        continue;
      }

      // copying images to temporary directory folder
      String newTempPath = '${DirectoryPathProvider.instance.tempDirPath}/${(basename(sharedImage.path).toLowerCase())}';
      tempImage = await sharedImage.copy(newTempPath);
      // print('saving file: ${basename(tempImage.path)}');
      sharedFiles.add(tempImage);

      sharedImage.delete();
    }

    ReceiveSharingIntent.reset();

    return sharedFiles;
  }

  Future<bool> _sharedFileIsZipFile(
      List<SharedMediaFile> sharedMediaFiles) async {
    try {
      if (sharedMediaFiles.length == 1) {
        final File sharedFile = File(sharedMediaFiles.first.path);

        if (extension(sharedFile.path) == '.zip') {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<File> _processZipMediaFile(SharedMediaFile sharedMediaFile) async {
    // removing URI scheme from path
    // this URI scheme is only present for zip files
    final String filePath = sharedMediaFile.path.replaceFirst('file://', '');
    final File sharedZipFile = File(filePath);

    // copying file to temporary directory folder
    File tempZipFile;
    String newTempPath =
        '${DirectoryPathProvider.instance.tempDirPath}/imported_receipts.zip';
    tempZipFile = await sharedZipFile.copy(newTempPath);
    return tempZipFile;
  }
}
