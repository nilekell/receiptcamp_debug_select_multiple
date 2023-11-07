import 'package:permission_handler/permission_handler.dart';

enum PermissionFailedResult { invalidCamera, invalidPhotos, unknown }

class PermissionsService {
  // singleton
  PermissionsService._privateConstructor();
  static final PermissionsService _instance =
      PermissionsService._privateConstructor();
  static PermissionsService get instance => _instance;

  final Permission cameraPermission = Permission.camera;
  final Permission photosPermission = Permission.photos;

  // setting initial values to be used in FolderViewCubit
  bool hasCameraAccess = false;
  bool hasPhotosAccess = false;

  PermissionFailedResult cameraResult = PermissionFailedResult.unknown;
  PermissionFailedResult photosResult = PermissionFailedResult.unknown;

  Future<void> requestCameraPermission() async {
    if (hasCameraAccess) return;

    try {
      // no request is shown if user has already granted permission
      final status = await cameraPermission.request();

      switch (status) {
        case PermissionStatus.granted:
          hasCameraAccess = true;
          return;
        case PermissionStatus.limited: // iOS only
          hasCameraAccess = true;
          return;
        case PermissionStatus.denied:
          cameraResult = PermissionFailedResult.invalidCamera;
          hasCameraAccess = false;
          return;
        case PermissionStatus.permanentlyDenied:
          cameraResult = PermissionFailedResult.invalidCamera;
          hasCameraAccess = false;
          return;
        case PermissionStatus.restricted: // iOS only
          cameraResult = PermissionFailedResult.invalidCamera;
          hasCameraAccess = false;
          return;
        case PermissionStatus.provisional: // iOS only
          // this permission can be ignored, regards notification perms only
          return;
      }
    } on Exception catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<void> requestPhotosPermission() async {
    if (hasPhotosAccess) return;

    try {
      final status = await photosPermission.request();

      switch (status) {
        case PermissionStatus.granted:
          hasPhotosAccess = true;
          return;
        case PermissionStatus.limited: // iOS only
          hasPhotosAccess = true;
          return;
        case PermissionStatus.denied:
          photosResult = PermissionFailedResult.invalidPhotos;
          hasPhotosAccess = false;
          return;
        case PermissionStatus.permanentlyDenied:
          photosResult = PermissionFailedResult.invalidPhotos;
          hasPhotosAccess = false;
          return;
        case PermissionStatus.restricted: // iOS only
          photosResult = PermissionFailedResult.invalidPhotos;
          hasPhotosAccess = false;
          return;
        case PermissionStatus.provisional: // iOS only
          // this permission can be ignored, regards notification perms only
          return;
      }
    } on Exception catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}
