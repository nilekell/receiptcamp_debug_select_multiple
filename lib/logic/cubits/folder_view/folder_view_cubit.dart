import 'package:bloc/bloc.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:receiptcamp/data/data_constants.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/data/services/permissons.dart';
import 'package:receiptcamp/data/services/preferences.dart';
import 'package:receiptcamp/data/utils/file_helper.dart';
import 'package:receiptcamp/data/utils/receipt_helper.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/logic/blocs/home/home_bloc.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/models/tag.dart';

part 'folder_view_state.dart';

// this cubit controls the initialisation, loading, displaying and any methods that can
// affect what is currently being displayed in the folder view e.g. move/delete/upload/rename
class FolderViewCubit extends Cubit<FolderViewState> {

  final HomeBloc homeBloc;
  final PreferencesService prefs; 

  FolderViewCubit({required this.homeBloc, required this.prefs}) : super(FolderViewInitial());

  // init folderview
  initFolderView() {
    emit(FolderViewInitial());
    print('RefreshableFolderView instantiated');
    fetchFilesInFolderSortedBy(rootFolderId, column: prefs.getLastColumn(), order: prefs.getLastOrder());
  }

  // get folder files
  fetchFilesInFolderSortedBy(String folderId, {String? column, String? order, bool userSelectedSort = false}) async {
    emit(FolderViewLoading());

    // if column and order are left out of the method call (null), set them to the last value
    column ??= prefs.getLastColumn();
    order ??= prefs.getLastOrder();

    try {
      // userSelectedSort is true when the user taps on a tile in order options bottom sheet
      // this distinguishes between the user navigating between folders and sorting in the options sheet
      if (userSelectedSort && _isSameSort(order, column)) {
        // toggles order when the user has submitted the same sort
        order = order == 'ASC' ? 'DESC' : 'ASC';
      }

      final folder = await DatabaseRepository.instance.getFolderById(folderId);

      if (column == 'storageSize') {
        final List<FolderWithSize> foldersWithSize = await DatabaseRepository.instance.getFoldersByTotalReceiptSize(folderId, order);
        final List<ReceiptWithSize> receiptsWithSize =  await DatabaseRepository.instance.getReceiptsBySize(folderId, order);
        final List<Object> files = [...foldersWithSize, ...receiptsWithSize];
        emit(FolderViewLoadedSuccess(files: files, folder: folder, orderedBy: column, order: order));

        // updating last column and last order
        await prefs.setLastColumn(column);
        await prefs.setLastOrder(order);
        return;
      }

      final List<Folder> folders = await DatabaseRepository.instance.getFoldersInFolderSortedBy(folderId, column, order);
      final List<Receipt> receipts = await DatabaseRepository.instance.getReceiptsInFolderSortedBy(folderId, column, order);
      final List<Object> files = [...folders, ...receipts];
      emit(FolderViewLoadedSuccess(files: files, folder: folder, orderedBy: column, order: order));

      // updating last column and last order
      await prefs.setLastColumn(column);
      await prefs.setLastOrder(order);

    } catch (error) {
      emit(FolderViewError());
    }
  }

  // determines if the last selected order and column is the same as the next selected order and column
  bool _isSameSort(String currentOrder, currentColumn) {
    return currentOrder == prefs.getLastOrder() && currentColumn == prefs.getLastColumn();
  }

  // move folder
  moveFolder(Folder folder, String targetFolderId) async {
    final String targetFolderName =
        (await DatabaseRepository.instance.getFolderById(targetFolderId)).name;
    try {
      await DatabaseRepository.instance.moveFolder(folder, targetFolderId);
      emit(FolderViewMoveSuccess(
          oldName: folder.name,
          newName: targetFolderName,
          folderId: folder.parentId));
      fetchFilesInFolderSortedBy(folder.parentId);
    } on Exception catch (e) {
      print(e.toString());
      emit(FolderViewMoveFailure(
          oldName: folder.name,
          newName: targetFolderName,
          folderId: folder.parentId));
    }
  }

  // delete folder
  deleteFolder(String folderId) async {
    final Folder deletedFolder =
        await DatabaseRepository.instance.getFolderById(folderId);
    try {
      await DatabaseRepository.instance.deleteFolder(folderId);
      emit(FolderViewDeleteSuccess(
          deletedName: deletedFolder.name, folderId: deletedFolder.parentId));

      
      // notifying home bloc to reload when a folder is deleted
      homeBloc.add(HomeLoadReceiptsEvent());
      
      fetchFilesInFolderSortedBy(deletedFolder.parentId);

    } on Exception catch (e) {
      print(e.toString());
      emit(FolderViewDeleteFailure(
          deletedName: deletedFolder.name, folderId: deletedFolder.parentId));
    }
  }

// upload folder
  uploadFolder(String folderName, String parentFolderId) async {
    try {
      // creating folder id
      final folderId = Utility.generateUid();
      final currentTime = Utility.getCurrentTime();

      // create folder object
      final folder = Folder(
          id: folderId,
          name: folderName,
          lastModified: currentTime,
          parentId: parentFolderId);

      // save folder
      DatabaseRepository.instance.insertFolder(folder);

      emit(FolderViewUploadSuccess(
          uploadedName: folder.name, folderId: folder.parentId));
      fetchFilesInFolderSortedBy(parentFolderId);
    } on Exception catch (e) {
      print('Error in uploadFolder: $e');
      emit(FolderViewError());
    }
  }

// rename folder
  renameFolder(Folder folder, String newName) async {
    try {
      await DatabaseRepository.instance.renameFolder(folder.id, newName);
      emit(FolderViewRenameSuccess(
          oldName: folder.name, newName: newName, folderId: folder.parentId));
      fetchFilesInFolderSortedBy(folder.parentId);
    } on Exception catch (e) {
      print(e.toString());
      emit(FolderViewRenameFailure(
          oldName: folder.name, newName: newName, folderId: folder.parentId));
    }
  }

// move receipt
  moveReceipt(Receipt receipt, String targetFolderId) async {
    final String targetFolderName =
        (await DatabaseRepository.instance.getFolderById(targetFolderId)).name;
    try {
      await DatabaseRepository.instance.moveReceipt(receipt, targetFolderId);
      emit(FolderViewMoveSuccess(
          oldName: receipt.name,
          newName: targetFolderName,
          folderId: receipt.parentId));
      fetchFilesInFolderSortedBy(receipt.parentId);
    } on Exception catch (e) {
      print(e.toString());
      emit(FolderViewMoveFailure(
          oldName: receipt.name,
          newName: targetFolderName,
          folderId: receipt.parentId));
    }
  }

// delete receipt
  deleteReceipt(String receiptId) async {
    final Receipt deletedReceipt =
        await DatabaseRepository.instance.getReceiptById(receiptId);
    try {
      await DatabaseRepository.instance.deleteReceipt(receiptId);
      emit(FolderViewDeleteSuccess(
          deletedName: deletedReceipt.name, folderId: deletedReceipt.parentId));
      
      // notifying home bloc to reload when a receipt is deleted
      homeBloc.add(HomeLoadReceiptsEvent());

      fetchFilesInFolderSortedBy(deletedReceipt.parentId);

    } on Exception catch (e) {
      print(e.toString());
      emit(FolderViewDeleteFailure(
          deletedName: deletedReceipt.name, folderId: deletedReceipt.parentId));
    }
  }

// upload receipt
  uploadReceiptFromGallery(String currentFolderId) async {
    // Requesting photos permission if not granted
    if (!PermissionsService.instance.hasPhotosAccess) {
      await PermissionsService.instance.requestPhotosPermission();
      // if user denies camera permissions, show failure snackbar
      if (!PermissionsService.instance.hasPhotosAccess) {
        emit(FolderViewPermissionsFailure(
            folderId: currentFolderId,
            permissionResult: PermissionsService.instance.photosResult));
        fetchFilesInFolderSortedBy(currentFolderId);
        return;
      }
    }

    try {
      final ImagePicker imagePicker = ImagePicker();
      final XFile? receiptImage =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if (receiptImage == null) {
        return;
      }

      final (validImage as bool, invalidImageReason as ValidationError) =
          await ReceiptService.isValidImage(receiptImage.path);
      if (!validImage) {
        emit(FolderViewUploadFailure(folderId: currentFolderId, validationType: invalidImageReason));
        fetchFilesInFolderSortedBy(currentFolderId);
        return;
      }

      final List<dynamic> results =
          await ReceiptService.processingReceiptAndTags(
              receiptImage, currentFolderId);
      final Receipt receipt = results[0];
      final List<Tag> tags = results[1];

      await DatabaseRepository.instance.insertTags(tags);
      await DatabaseRepository.instance.insertReceipt(receipt);
      print('Image ${receipt.name} saved at ${receipt.localPath}');

      emit(FolderViewUploadSuccess(
          uploadedName: receipt.name, folderId: receipt.parentId));

      // notifying home bloc to reload when a receipt is uploaded from gallery
      homeBloc.add(HomeLoadReceiptsEvent());

      fetchFilesInFolderSortedBy(receipt.parentId);

    } on Exception catch (e) {
      print('Error in uploadReceipt: $e');
      emit(FolderViewError());
    }
  }

  uploadReceiptFromCamera(String currentFolderId) async {
    // Requesting camera permission if not granted
    if (!PermissionsService.instance.hasCameraAccess) {
      await PermissionsService.instance.requestCameraPermission();
      if (!PermissionsService.instance.hasCameraAccess) {
        emit(FolderViewPermissionsFailure(
            folderId: currentFolderId,
            permissionResult: PermissionsService.instance.cameraResult));
        fetchFilesInFolderSortedBy(currentFolderId);
        return;
      }
    }

    try {
      final ImagePicker imagePicker = ImagePicker();
      final XFile? receiptPhoto =
          await imagePicker.pickImage(source: ImageSource.camera);
      if (receiptPhoto == null) {
        return;
      }

      final (validImage as bool, invalidImageReason as ValidationError) =
          await ReceiptService.isValidImage(receiptPhoto.path);
      if (!validImage) {
        emit(FolderViewUploadFailure(folderId: currentFolderId, validationType: invalidImageReason));
        fetchFilesInFolderSortedBy(currentFolderId);
        return;
      }

      final List<dynamic> results =
          await ReceiptService.processingReceiptAndTags(
              receiptPhoto, currentFolderId);
      final Receipt receipt = results[0];
      final List<Tag> tags = results[1];

      await DatabaseRepository.instance.insertTags(tags);
      await DatabaseRepository.instance.insertReceipt(receipt);
      print('Image ${receipt.name} saved at ${receipt.localPath}');

      emit(FolderViewUploadSuccess(
          uploadedName: receipt.name, folderId: receipt.parentId));

      // notifying home bloc to reload when a receipt is uploaded from camera
      homeBloc.add(HomeLoadReceiptsEvent());
      
      fetchFilesInFolderSortedBy(receipt.parentId);

    } on Exception catch (e) {
      print('Error in uploadReceipt: $e');
      emit(FolderViewError());
    }
  }

  uploadReceiptFromDocumentScan(String currentFolderId) async {
    // Requesting camera permission if not granted
    if (!PermissionsService.instance.hasCameraAccess) {
      await PermissionsService.instance.requestCameraPermission();
      if (!PermissionsService.instance.hasCameraAccess) {
        emit(FolderViewPermissionsFailure(
            folderId: currentFolderId,
            permissionResult: PermissionsService.instance.cameraResult));
        fetchFilesInFolderSortedBy(currentFolderId);
        return;
      }
    }

    try {
      List<String> validatedImagePaths = [];

      final scannedImagePaths = await CunningDocumentScanner.getPictures();
      if (scannedImagePaths == null) {
        return;
      }

      // iterating over scanned images and checking image size and if they contain text
      for (final path in scannedImagePaths) {
        final (validImage as bool, invalidImageReason as ValidationError) =
            await ReceiptService.isValidImage(path);
        if (!validImage) {
          // if a single image fails the validation, all images are discarded
          emit(FolderViewUploadFailure(folderId: currentFolderId, validationType: invalidImageReason));
          fetchFilesInFolderSortedBy(currentFolderId);
          return;
        }
        // only adding images that pass validations to list
        validatedImagePaths.add(path);
      }
      // only iterating over validated images and uploading them consecutively
      for (final path in validatedImagePaths) {
        final XFile receiptDocument = XFile(path);
        final List<dynamic> results =
            await ReceiptService.processingReceiptAndTags(
                receiptDocument, currentFolderId);
        final Receipt receipt = results[0];
        final List<Tag> tags = results[1];

        await DatabaseRepository.instance.insertTags(tags);
        await DatabaseRepository.instance.insertReceipt(receipt);
        print('Image ${receipt.name} saved at ${receipt.localPath}');

        emit(FolderViewUploadSuccess(
            uploadedName: receipt.name, folderId: receipt.parentId));
      }
      
      // notifying home bloc to reload when a receipt is uploaded from document scan
      homeBloc.add(HomeLoadReceiptsEvent());
      
      fetchFilesInFolderSortedBy(currentFolderId);

    } on Exception catch (e) {
      print('Error in uploadReceipt: $e');
      emit(FolderViewError());
    }
  }

  // rename receipt
  renameReceipt(Receipt receipt, String newName) async {
    try {
      await DatabaseRepository.instance.renameReceipt(receipt.id, newName);
      emit(FolderViewRenameSuccess(
          oldName: receipt.name, newName: newName, folderId: receipt.parentId));

      // notifying home bloc to reload when a receipt is renamed
      homeBloc.add(HomeLoadReceiptsEvent());
      
      fetchFilesInFolderSortedBy(receipt.parentId);

    } on Exception catch (e) {
      print(e.toString());
      emit(FolderViewRenameFailure(
          oldName: receipt.name, newName: newName, folderId: receipt.parentId));
      fetchFilesInFolderSortedBy(receipt.parentId, useCachedFiles: true);
    }
  }

  generateZipFile(Folder folder, bool withPdfs) async {

    final folderIsEmpty = await DatabaseRepository.instance.folderIsEmpty(folder.id);
    
    if (folderIsEmpty) {
      emit(FolderViewFileEmpty(folder: folder, files: cachedCurrentlyDisplayedFiles, orderedBy: prefs.getLastColumn(), order: prefs.getLastOrder(),));
      fetchFilesInFolderSortedBy(folder.parentId, useCachedFiles: true);
      return;
    }

    emit(FolderViewFileLoading(files: cachedCurrentlyDisplayedFiles, folder: folder, orderedBy: prefs.getLastColumn(), order: prefs.getLastOrder()));

    try {
      Map<String, dynamic> serializedFolder = folder.toMap();

      Map<String, dynamic> computeParams = {
        'folder': serializedFolder,
        'withPdfs': withPdfs
      };

      // Prepare data to pass to isolate
      final isolateParams = IsolateParams(
        computeParams: computeParams,
        rootToken: RootIsolateToken.instance!,
      );

      final receivePort = ReceivePort();
      await Isolate.spawn(IsolateService.zipFileEntryFunction, {
        'isolateParams': isolateParams,
        'sendPort': receivePort.sendPort,
      });

      // Receive data back from the isolate
      final File zipFile = await receivePort.first;

      emit(FolderViewFileLoaded(zipFile: zipFile, files: cachedCurrentlyDisplayedFiles, folder: folder, orderedBy: prefs.getLastColumn(), order: prefs.getLastOrder()));
    } on Exception catch (e) {
      print(e.toString());
      emit(FolderViewFileError(files: cachedCurrentlyDisplayedFiles, folder: folder, orderedBy: prefs.getLastColumn(), order: prefs.getLastOrder()));
      fetchFilesInFolderSortedBy(folder.parentId, useCachedFiles: true);
    }
  }

  // share folder
  shareFolder(Folder folder, File zipFile) async {
    try {
      await FileService.shareFolderAsZip(folder, zipFile);
    } on Exception catch (e) {
      print(e.toString());
      emit(FolderViewShareFailure(errorMessage: e.toString(), folderId: folder.id, folderName: folder.name));
      fetchFilesInFolderSortedBy(folder.parentId, useCachedFiles: true);
    }
  }
}
