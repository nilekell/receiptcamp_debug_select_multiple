import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:receiptcamp/logic/cubits/sharing_intent/sharing_intent_cubit.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

class SlidingReceiptSharingTransitionRoute extends PageRouteBuilder {
  SlidingReceiptSharingTransitionRoute()
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
              child: const ReceiptSharingView(),
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
              child: BlocProvider.value(value: context.read<SharingIntentCubit>(),
              child: const ReceiptSharingView(),),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

class ReceiptSharingView extends StatefulWidget {
  const ReceiptSharingView({super.key});

  @override
  State<ReceiptSharingView> createState() =>
      _ReceiptSharingViewState();
}

class _ReceiptSharingViewState extends State<ReceiptSharingView>
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
    _focusNode.dispose();
  }

  Future<void> _showProcessingDialog(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: ((context) {
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
                      "Inserting receipts into folder...",
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ),
          );
        }));
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
              "Failed to create excel sheet, please try again later",
              style: TextStyle(color: Colors.white),
            ),
          );
        }));
  }

  // aligning title text in row depending on platform
  final titleMainAxisSize =
      Platform.isAndroid ? MainAxisSize.max : MainAxisSize.min;

  final FocusNode _focusNode = FocusNode();

  final TextStyle displayNameStyle = const TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, color: Color(primaryGrey));

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
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.close, size: 26,),
                onPressed: () => Navigator.of(context).pop()),
            backgroundColor: const Color(primaryDarkBlue),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: titleMainAxisSize,
              children: const [
                Text(
                  'Confirm receipt prices',
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
                  }),
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
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: state.files.length,
                            itemBuilder: (context, index) {
                              final file = state.files[index];
                              final fileName = basename(file.path);
                              final displayName = fileName.length > 25
                                  ? "${fileName.substring(0, 25)}..."
                                  : fileName.split('.').first;
                              return Container(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  key: UniqueKey(),
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
                                            const BorderRadius.all(Radius.zero),
                                        child: Image.file(
                                          File(file.path),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(displayName,
                                        style: displayNameStyle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                );
            }
          })),
    );
  }
}
