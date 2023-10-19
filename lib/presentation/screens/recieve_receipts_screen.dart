import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:receiptcamp/logic/cubits/sharing_intent/sharing_intent_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

class SlidingReceiveReceiptTransitionRoute extends PageRouteBuilder {
  final List<File> receiptFiles;
  
  SlidingReceiveReceiptTransitionRoute({required this.receiptFiles})
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
              child: ReceiveReceiptView(receiptFiles: receiptFiles),
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
                child: ReceiveReceiptView(receiptFiles: receiptFiles,),
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

class ReceiveReceiptView extends StatefulWidget {
  const ReceiveReceiptView({super.key, required this.receiptFiles});

  final List<File> receiptFiles;

  @override
  State<ReceiveReceiptView> createState() => _ReceiveReceiptViewState();
}

class _ReceiveReceiptViewState extends State<ReceiveReceiptView>
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

  @override
  void dispose() {
    widget.receiptFiles.clear();
    _animationController.dispose();
    super.dispose();
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
                "Processing images...",
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
    );
  }
  Future<void> _showProcessingDialog(BuildContext context) async {
    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (context) {
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
                      "Importing receipts...",
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ),
          );
        });
  }

  void _showSavedReceiptSnackBar(BuildContext context, Receipt receipt) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: const Color(primaryDeepBlue),
      behavior: SnackBarBehavior.floating,
      content: Text("'${receipt.name}' added successfully"),
      duration: const Duration(seconds: 2),
    ));
  }

  // aligning title text in row depending on platform
  final titleMainAxisSize =
      Platform.isAndroid ? MainAxisSize.max : MainAxisSize.min;

  final TextStyle displayNameStyle = const TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, color: Color(primaryGrey));

  final ValueNotifier<Folder?> selectedFolderNotifier =
      ValueNotifier<Folder?>(null);

  @override
  Widget build(BuildContext context) {
    return BlocListener<SharingIntentCubit, SharingIntentState>(
      listener: (context, state) {
        switch (state) {
          case SharingIntentSavingReceipts():
            _showProcessingDialog(context);
          case SharingIntentClose():
            // closing _showProcessingDialog
            Navigator.of(context).pop();
            // closing ReceiveReceiptView
            Navigator.of(context).pop();
            for (final receipt in state.savedReceipts) {
              _showSavedReceiptSnackBar(context, receipt);
            }
          default:
            return;
        }
      },
      child: Scaffold(
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
                  'Import receipts',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
            actions: [
              ValueListenableBuilder(
                  valueListenable: selectedFolderNotifier,
                  builder: (context, Folder? selectedFolder, child) {
                    return IconButton(
                        icon: const Icon(Icons.save_alt),
                        onPressed: selectedFolderNotifier.value == null
                            ? null
                            : () {
                              print('inserting receipts: ${widget.receiptFiles}');
                                context
                                    .read<SharingIntentCubit>()
                                    .insertReceiptsIntoFolder(
                                        selectedFolderNotifier.value!.id,
                                        widget.receiptFiles);
                              });
                  }),
            ],
          ),
          body: BlocBuilder<SharingIntentCubit, SharingIntentState>(
              builder: (context, state) {
            switch (state) {
              case SharingIntentError():
                return _showErrorDialog(context, "Uh oh, an unexpected error occured. Please go back and/or report the error");
              case SharingIntentNoValidFiles():
                return _showErrorDialog(context, "Sorry, these images don't seem to be receipts so they can't be imported.");
              case SharingIntentLoading() || SharingIntentFilesRecieved():
                return _showLoadingDialog(context);
              case SharingIntentSuccess():
                _animationController.forward(from: 0.0);
                return FadeTransition(
                  opacity: _animationController,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: widget.receiptFiles.length,
                                itemBuilder: (context, index) {
                                  final file = widget.receiptFiles[index];
                                  final fileName = basename(file.path);
                                  final displayName = (fileName.length > 25
                                          ? "${fileName.substring(0, 25)}..."
                                          : fileName.split('.').first)
                                      .toUpperCase();
                                  return Column(
                                    children: [
                                      // adding padding above first ListTile
                                      index == 0
                                          ? const SizedBox(
                                              height: 20,
                                            )
                                          : const SizedBox.shrink(),
                                      Container(
                                        padding: const EdgeInsets.all(16.0),
                                        child: ListTile(
                                          leading: Container(
                                            height: 100,
                                            width: 50,
                                            decoration: const BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.all(Radius.zero),
                                            ),
                                            child: Transform.translate(
                                              offset: const Offset(0, -6),
                                              child: ClipRRect(
                                                // square image corners
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.zero),
                                                child: Image.file(
                                                  File(file.path),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          title: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: Text(displayName,
                                                style: displayNameStyle,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                        ),
                                      ),
                                      // adding dividers between ListTiles
                                      index != widget.receiptFiles.length - 1
                                          ? const Divider(
                                              thickness: 2,
                                              height: 1,
                                              indent: 25,
                                              endIndent: 25,
                                            )
                                          : const SizedBox.shrink(),
                                      // adding padding after last ListTile
                                      index != widget.receiptFiles.length - 1
                                          ? const SizedBox.shrink()
                                          : const SizedBox(
                                              height: 40,
                                            ),
                                    ],
                                  );
                                }),
                          ),
                        ],
                      ),
                      // Select Folder DropDown Button
                      Positioned(
                        bottom: 40,
                        left: 20,
                        right: 20,
                        child: Center(
                          child: ValueListenableBuilder<Folder?>(
                              valueListenable: selectedFolderNotifier,
                              builder:
                                  (context, Folder? selectedFolder, child) {
                                return DropdownButtonHideUnderline(
                                  child: DropdownButton2<Folder>(
                                    isExpanded: true,
                                    hint: Row(
                                      children: [
                                        const Icon(
                                          Icons.folder,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        Expanded(
                                          child: Text(
                                            selectedFolder == null
                                                ? 'Select Folder'
                                                : selectedFolder.name,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    items: state.folders
                                        .map((Folder folder) =>
                                            DropdownMenuItem<Folder>(
                                              value: folder,
                                              child: Text(
                                                folder.name,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    value: selectedFolder,
                                    onChanged: (value) {
                                      selectedFolderNotifier.value = value;
                                    },
                                    buttonStyleData: ButtonStyleData(
                                      height: 50,
                                      // width: 160,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.black26,
                                        ),
                                        color: const Color(primaryDeepBlue),
                                      ),
                                      elevation: 2,
                                    ),
                                    iconStyleData: const IconStyleData(
                                      icon: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                      ),
                                      iconSize: 20,
                                      iconEnabledColor: Colors.white,
                                      iconDisabledColor: Colors.white,
                                    ),
                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 200,
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: const Color(primaryDeepBlue),
                                      ),
                                      offset: const Offset(20, 0),
                                      scrollbarTheme: ScrollbarThemeData(
                                        radius: const Radius.circular(40),
                                        thumbColor: MaterialStateProperty.all(
                                            Colors.white),
                                        thickness: MaterialStateProperty.all(6),
                                        thumbVisibility:
                                            MaterialStateProperty.all(true),
                                      ),
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 40,
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
                    ],
                  ),
                );
            default:
              return Container();}
          })),
    );
  }
}
