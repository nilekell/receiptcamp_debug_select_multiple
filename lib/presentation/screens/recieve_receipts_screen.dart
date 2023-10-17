import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:receiptcamp/logic/cubits/sharing_intent/sharing_intent_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

class SlidingReceiveReceiptTransitionRoute extends PageRouteBuilder {
  SlidingReceiveReceiptTransitionRoute()
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
              child: const ReceiveReceiptView(),
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
                child: const ReceiveReceiptView(),
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

class ReceiveReceiptView extends StatefulWidget {
  const ReceiveReceiptView({super.key});

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
    super.dispose();
    _animationController.dispose();
  }

  Future<void> _showErrorDialog(BuildContext context) {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: ((context) {
          return const AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(40.0))),
            backgroundColor: Color(primaryDeepBlue),
            content: Text(
              "Failed to import files, please try again later",
              style: TextStyle(color: Colors.white),
            ),
          );
        }));
  }

  // aligning title text in row depending on platform
  final titleMainAxisSize =
      Platform.isAndroid ? MainAxisSize.max : MainAxisSize.min;

  final TextStyle displayNameStyle = const TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, color: Color(primaryGrey));

  final ValueNotifier<Folder?> selectedFolderNotifier = ValueNotifier<Folder?>(null);


  @override
  Widget build(BuildContext context) {
    return BlocListener<SharingIntentCubit, SharingIntentState>(
      listener: (context, state) {
        switch (state) {
          case SharingIntentError():
            _showErrorDialog(context);
          default:
            return;
        }
      },
      child: Scaffold(
          bottomNavigationBar: Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent
            ),
            child: BottomNavigationBar(
              onTap: null,
              backgroundColor: const Color(primaryDarkBlue),
              items: const [
              BottomNavigationBarItem(icon: Text(''), label: ''),
              BottomNavigationBarItem(icon: Text(''), label: '',)
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
                    onPressed:  selectedFolderNotifier.value == null
                        ? null
                        : () {
                          print('saving folder to ${selectedFolderNotifier.value!.name}');
                          
                        }
                            
                  );
                } 
              ),
            ],
          ),
          body: BlocBuilder<SharingIntentCubit, SharingIntentState>(
              builder: (context, state) {
            switch (state) {
              case SharingIntentFilesRecieved() || SharingIntentLoading():
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
                            "Processing receipts...",
                            style: TextStyle(color: Colors.white),
                          )),
                    ],
                  ),
                );
              case SharingIntentError():
                return Column(
                  children: [
                    const Text(
                        'Uh oh, an unexpected error occured. Please go back and/or report the error'),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Go back'))
                  ],
                );
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
                                itemCount: state.files.length,
                                itemBuilder: (context, index) {
                                  final file = state.files[index];
                                  final fileName = basename(file.path);
                                  final displayName = (fileName.length > 25
                                      ? "${fileName.substring(0, 25)}..."
                                      : fileName.split('.').first).toUpperCase();
                                  return Column(
                                    children: [
                                      index == 0 ? const SizedBox(height: 20,) : const SizedBox.shrink(),
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
                                            padding:
                                                const EdgeInsets.only(bottom: 8.0),
                                            child: Text(displayName,
                                                style: displayNameStyle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis),
                                          ),
                                        ),
                                      ),
                                      index != state.files.length - 1 ? const Divider(
                                        thickness: 2,
                                        height: 1,
                                        indent: 25,
                                        endIndent: 25,
                                      ) : const SizedBox.shrink(),
                                      index != state.files.length - 1 ? const SizedBox.shrink() : const SizedBox(height: 40,),
                                    ],
                                  );
                                }),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 40,
                        left: 20,
                        right: 20,
                        child: Center(
                          child: ValueListenableBuilder<Folder?>(
                            valueListenable: selectedFolderNotifier,
                            builder: (context, Folder? selectedFolder, child) {
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
                                        selectedFolder == null ? 'Select Folder' : selectedFolder.name,
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
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 14),
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
            }
          })),
    );
  }
}
