// ignore_for_file: unused_field

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:receiptcamp/logic/cubits/sharing_intent/sharing_intent_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

class SlidingImportTransitionRoute extends PageRouteBuilder {
  final File zipFile;

  SlidingImportTransitionRoute({required this.zipFile})
      : super(
          opaque: false,
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return Dismissible(
              onDismissed: (direction) {
                Navigator.of(context).pop();
              },
              key: UniqueKey(),
              direction: DismissDirection.down,
              child: ImportView(
                zipFile: zipFile,
              ),
            );
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;

            const curve = Curves.easeInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: BlocProvider.value(
                value: context.read<SharingIntentCubit>(),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

class ImportView extends StatefulWidget {
  const ImportView({super.key, required this.zipFile});

  final File zipFile;

  @override
  State<ImportView> createState() => _ImportViewState();
}

final titleMainAxisSize =
    Platform.isAndroid ? MainAxisSize.max : MainAxisSize.min;

class _ImportViewState extends State<ImportView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    super.initState();
  }

  Widget _showErrorDialog(BuildContext context, String message) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40.0))),
      backgroundColor: const Color(primaryDeepBlue),
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _showLoadingDialog(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40.0))),
      backgroundColor: const Color(primaryDeepBlue),
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 16),
              child: const Text(
                "Processing archive...",
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Theme(
        data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent),
        child: BottomNavigationBar(
            onTap: null,
            backgroundColor: const Color(primaryDarkBlue),
            items: const [
              BottomNavigationBarItem(icon: Text(''), label: ''),
              BottomNavigationBarItem(
                icon: Text(''),
                label: '',
              )
            ]),
      ),
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(
              Icons.close,
              size: 26,
            ),
            onPressed: () => Navigator.of(context).pop()),
        backgroundColor: const Color(primaryDarkBlue),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: titleMainAxisSize,
          children: const [
            Text(
              'Imported Expenses',
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.save_alt),
              onPressed: () {
                // start saving folders and receipts
                // show loading dialog while this occurs
              })
        ],
      ),
      body: BlocBuilder<SharingIntentCubit, SharingIntentState>(
        builder: (context, state) {
          switch (state) {
            case SharingIntentError():
              return _showErrorDialog(context,
                  "Uh oh, an unexpected error occured. Please go back and/or report the error");
            case SharingIntentLoading() || SharingIntentFilesRecieved():
              return _showLoadingDialog(context);
            case SharingIntentArchiveSuccess():
              print('SharingIntentArchiveSuccess');
              _animationController.forward(from: 0.0);
              return FadeTransition(
                opacity: _animationController,
                child: Column(
                  children: [
                    Expanded(
                        child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: state.items.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  index != 0 ? const Divider(
                                    thickness: 2,
                                    height: 1,
                                    indent: 25,
                                    endIndent: 25,
                                  ) : const SizedBox.shrink(),
                                  _buildItem(state, index),
                                ],
                              );
                            }))
                  ],
                ),
              );
            default:
              return const Text('Unkown state');
          }
        },
      ),
    );
  }
}

Widget _buildItem(SharingIntentArchiveSuccess state, int index) {
  final item = state.items[index];
  final List<File> images = List.from(state.imageFiles);
  if (item is Receipt) {
    final image = _getImageFromListByFileName(images, item);
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: ListTile(
        leading: Container(
          height: 100,
          width: 50,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.zero),
          ),
          child: Transform.translate(
            offset: const Offset(0, -6),
            child: ClipRRect(
              // square image corners
              borderRadius: const BorderRadius.all(Radius.zero),
              child: Image.file(
                File(image.path),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(item.name,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(primaryGrey)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  } else if (item is Folder) {
    if (item.name == 'Imported_Expenses') return const SizedBox.shrink();
    return Container(
        padding: const EdgeInsets.all(16.0),
        child: ListTile(
          leading: const Icon(
                  Icons.folder,
                  size: 50,
                ),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(item.name,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(primaryGrey)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ));
  } else {
    return Container();
  }
}

File _getImageFromListByFileName(List<File> imageFileList, Receipt item) {
  File? image;
  String imageFileName;
  for (final img in imageFileList) {
    imageFileName = basename(img.path);
    if (imageFileName == item.fileName) {
      image = img;
      imageFileList
          .removeWhere((element) => basename(element.path) == imageFileName);
      break;
    }
  }

  return image!;
}
