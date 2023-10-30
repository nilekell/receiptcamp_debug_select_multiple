// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_schema/json_schema.dart';
import 'package:path/path.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/data/services/directory_path_provider.dart';
import 'package:receiptcamp/data/utils/receipt_helper.dart';
import 'package:receiptcamp/logic/blocs/home/home_bloc.dart';
import 'package:receiptcamp/logic/cubits/file_explorer/file_explorer_cubit.dart';
import 'package:receiptcamp/logic/cubits/landing/landing_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/models/tag.dart';
import 'package:share_plus/share_plus.dart';
part 'sharing_intent_state.dart';

class SharingIntentCubit extends Cubit<SharingIntentState> {
  SharingIntentCubit(
      {required this.homeBloc,
      required this.fileExplorerCubit,
      required this.mediaStream,
      required this.initialMedia,
      required this.landingCubit})
      : super(SharingIntentFilesInitial());

  final HomeBloc homeBloc;
  final FileExplorerCubit fileExplorerCubit;
  final LandingCubit landingCubit;

  Stream<List<File>> mediaStream;
  Future<List<File>> initialMedia;

  void init() async {
    emit(SharingIntentFilesInitial());
    try {
      // print('SharingIntentCubit instantiated');

      List<File> files = <File>[];

      mediaStream.listen(
        (sharedFiles) async {
          if (sharedFiles.isEmpty) {
            emit(SharingIntentNoValidFiles());
            return;
          }

          if (await _sharedFileIsZipFile(sharedFiles)) {
            File zipFile = sharedFiles[0];
            // print('SharingIntentCubit: zip file recieved');
            emit(SharingIntentZipFileReceived(zipFile: zipFile));
            extractItemsFromArchiveFile(zipFile);
            return;
          }

          for (final f in sharedFiles) {
            files.add(f);
          }

          emit(SharingIntentFilesRecieved(files: files));

          // print("Received shared stream files: $sharedFiles");
          getFolders();
          return;
        },
        onError: (error) {
          print(error.toString());
          emit(SharingIntentError());
          files.clear();
          return;
        },
      );

      List<File> initialSharedFiles = await initialMedia;

      if (await _sharedFileIsZipFile(initialSharedFiles)) {
        File zipFile = initialSharedFiles[0];
        // print('SharingIntentCubit: zip file recieved');
        emit(SharingIntentZipFileReceived(zipFile: zipFile));
        extractItemsFromArchiveFile(zipFile);
        return;
      }

      if (initialSharedFiles.isNotEmpty) {
        // print("Received shared initial files: $initialSharedFiles");
        files = initialSharedFiles;
        emit(SharingIntentFilesRecieved(files: files));
        getFolders();
        return;
      } else {
        return;
      }
    } on Exception catch (e) {
      print(e.toString());
      emit(SharingIntentError());
    }
  }

  Future<bool> _sharedFileIsZipFile(List<File> sharedFiles) async {
    if (sharedFiles.length == 1) {
      final File sharedFile = File(sharedFiles.first.path);
      if (extension(sharedFile.path) == '.zip') {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  void getFolders() async {
    emit(SharingIntentLoading());
    try {
      final folders = await DatabaseRepository.instance.getFolders();
      emit(SharingIntentSuccess(folders: folders));
    } on Exception catch (e) {
      print(e.toString());
      emit(SharingIntentError());
    }
  }

  void insertReceiptsIntoFolder(
      String folderId, List<File> receiptFiles) async {
    emit(const SharingIntentSavingReceipts(folders: []));

    List<Receipt> savedReceipts = [];

    try {
      // iterating over images and uploading them as receipts consecutively
      // REFACTOR TO PROCESS IN BACKGROUND USING ISOLATE depending on number of files
      for (final file in receiptFiles) {
        final XFile receiptDocument = XFile(file.path);
        final List<dynamic> results =
            await ReceiptService.processingReceiptAndTags(
                receiptDocument, folderId);
        final Receipt receipt = results[0];
        final List<Tag> tags = results[1];

        await DatabaseRepository.instance.insertTags(tags);
        await DatabaseRepository.instance.insertReceipt(receipt);

        savedReceipts.add(receipt);
      }

      // notifying home bloc to reload after all receipts imported
      homeBloc.add(HomeLoadReceiptsEvent());
      // directly navigating to FileExplorer tab
      landingCubit.updateIndex(1);
      // navigating to parent folder in FileExplorer when RecieveReceiptView is closed
      // notifying fileExplorerCubit to reload after all receipts imported
      fileExplorerCubit.selectFolder(folderId);
      emit(SharingIntentClose(folders: const [], savedReceipts: savedReceipts));
    } on Exception catch (e) {
      print(e.toString());
      emit(SharingIntentError());
    }
  }

  extractItemsFromArchiveFile(File zipFile) async {
    try {
      // Use an InputFileStream to access the zip file without storing it in memory.
      final inputStream = InputFileStream(zipFile.path);
      final zipDecoder = ZipDecoder();
      // Decode the zip from the InputFileStream. The archive will have the contents of the
      // zip, without having stored the data in memory.
      final archive = ZipDecoder().decodeBuffer(inputStream);


      // Validate zip file structure before processing
      if (!isValidArchiveStructure(zipDecoder, inputStream)) {
        emit(SharingIntentInvalidArchive());
        return;
      }

      // Reset stream position after validation
      inputStream.reset();

      // convert zip file to folder file
      final String extractedZipFilePath =
          '${DirectoryPathProvider.instance.tempDirPath}/';
      extractArchiveToDisk(archive, extractedZipFilePath);

      // Initialize lists to hold Folder and Receipt objects
      final List<Folder> extractedFolders = [];
      final List<Receipt> extractedReceipts = [];
      final List<File> extractedImages = [];
      // iterate over archive to extract folders and zip files
      for (final file in archive) {
        // Check if this is a folder JSON
        if (file.name.contains('Objects/Folders/')) {
          final String folderJson = utf8.decode(file.content);
          final Folder folder = Folder.fromJson(folderJson);
          extractedFolders.add(folder);
        } // Check if this is a receipt JSON
        else if (file.name.contains('Objects/Receipts/')) {
          final String receiptJson = utf8.decode(file.content);
          final Receipt receipt = Receipt.fromJson(receiptJson);
          extractedReceipts.add(receipt);
        } // Check if this is an image file in the zip
        else if (file.name.contains('Images/')) {
          final File imageFile = File('$extractedZipFilePath${file.name}');
          extractedImages.add(imageFile);
        } else {
          emit(SharingIntentInvalidArchive());
          return;
        }
      }

      final List<Object> items =
          List.from([...extractedFolders, ...extractedReceipts]);
      // emit list of items and images
      emit(SharingIntentArchiveSuccess(
          items: items, imageFiles: extractedImages));
    } catch (e) {
      print(e.toString());
      emit(SharingIntentInvalidArchive());
    }
  }

  importItemsFromArchiveFile(List<Object> extractedItems,
      List<File> extractedImages, File zipFile) async {
    emit(SharingIntentSavingArchive(
        imageFiles: extractedImages, items: extractedItems));
    try {

      await DatabaseRepository.instance.deleteAllFoldersExceptRoot();

      for (final item in extractedItems) {
        if (item is Folder) {
          await DatabaseRepository.instance.insertFolder(item);
        } else if (item is Receipt) {
          await DatabaseRepository.instance.insertReceipt(item);
        }
      }

      for (final image in extractedImages) {
        await image.copy(
            '${DirectoryPathProvider.instance.appDocDirPath}/${basename(image.path)}');
      }

      // deleting temp zip file and folder
      await zipFile.delete(recursive: true);

      // resetting file explorer
      fileExplorerCubit.initializeFileExplorerCubit();

      // closing screen
      emit(SharingIntentArchiveClose(imageFiles: extractedImages, items: extractedItems));
    } on Exception catch (e) {
      print(e.toString());
      emit(SharingIntentInvalidArchive());
    }
  }
  
  bool isValidArchiveStructure(
      ZipDecoder zipDecoder, InputFileStream inputStream) {
    final archive = zipDecoder.decodeBuffer(inputStream);

    bool hasImages = false;
    bool hasReceipts = false;
    bool hasFolders = false;

    // Regular expression to match image file extensions: .jpg, .jpeg, .png
    final RegExp imageRegex =
        RegExp(r"\.(jpg|jpeg|png)$", caseSensitive: false);

    final String folderJsonSchemaString = jsonEncode({
      "type": "object",
      "properties": {
        "id": {"type": "string"},
        "name": {"type": "string"},
        "parentId": {"type": "string"},
        "lastModified": {"type": "integer"}
      },
      "required": ["id", "name", "parentId", "lastModified"],
    });

    final String receiptJsonSchemaString = jsonEncode({
      "type": "object",
      "properties": {
        "id": {"type": "string"},
        "name": {"type": "string"},
        "fileName": {"type": "string"},
        "dateCreated": {"type": "integer"},
        "lastModified": {"type": "integer"},
        "storageSize": {"type": "integer"},
        "parentId": {"type": "string"}
      },
      "required": [
        "id",
        "name",
        "fileName",
        "dateCreated",
        "lastModified",
        "storageSize",
        "parentId"
      ]
    });

    final JsonSchema folderJsonSchema =
        JsonSchema.create(json.decode(folderJsonSchemaString));
    final JsonSchema receiptJsonSchema = JsonSchema.create(
        json.decode(receiptJsonSchemaString));

    for (final file in archive) {
      if (file.name.contains('Images/') && imageRegex.hasMatch(file.name)) {
        hasImages = true;
      } else if (file.name.contains('Objects/Receipts/') &&
          file.name.endsWith('.json')) {
          final String receiptJson = utf8.decode(file.content);
          final validationResult =
              receiptJsonSchema.validate(jsonDecode(receiptJson));
          // print('${file.name} is valid');
        if (validationResult.isValid) {
          // print('${file.name} is valid');
          hasReceipts = true;
        } else if (!validationResult.isValid) {
          // print('${file.name} is invalid');
          return false;
        }
      } else if (file.name.contains('Objects/Folders/') &&
          file.name.endsWith('.json')) {
        final String folderJson = utf8.decode(file.content);
        final validationResult =
            folderJsonSchema.validate(jsonDecode(folderJson));
        if (validationResult.isValid) {
          // print('${file.name} is valid');
          print('${file.name} is valid');
          hasFolders = true;
        } else if (!validationResult.isValid) {
          // print('${file.name} is invalid');
          return false;
        }
      }
    }

    return hasImages && hasReceipts && hasFolders;

  }
}
