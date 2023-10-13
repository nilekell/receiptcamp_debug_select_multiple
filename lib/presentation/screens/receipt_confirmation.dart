import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/utils/file_helper.dart';
import 'package:receiptcamp/logic/cubits/confirm_receipt/confirm_receipt_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/presentation/screens/image_view.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

// defining a custom route class to animate transition
class SlidingTransitionRoute extends PageRouteBuilder {
  SlidingTransitionRoute({required Folder folder})
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
              child: ReceiptConfirmationView(
                folder: folder,
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
              child: BlocProvider(
                  create: (BuildContext context) =>
                      ConfirmReceiptCubit()..getInitialExcelReceipts(folder.id),
                  child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

class ReceiptConfirmationView extends StatefulWidget {
  const ReceiptConfirmationView({Key? key, required this.folder})
      : super(key: key);

  final Folder folder;

  @override
  State<ReceiptConfirmationView> createState() =>
      _ReceiptConfirmationViewState();
}

class _ReceiptConfirmationViewState extends State<ReceiptConfirmationView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<ExcelReceipt> receiptsToShare = [];

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

  void _showEmptySnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Color(primaryDeepBlue),
      behavior: SnackBarBehavior.floating,
      content: Text("Folder is empty, add some receipts to export"),
      duration: Duration(milliseconds: 2000),
    ));
  }

  Future<void> _handleExcelSharing() async {
    final excelFile = await FileService.createExcelSheetfromReceipts(
        receiptsToShare, widget.folder);
    await FileService.shareFolderAsExcel(widget.folder, excelFile)
        .whenComplete(() => Navigator.of(context).pop());
  }

  // aligning title text in row depending on platform
  final titleMainAxisSize =
      Platform.isAndroid ? MainAxisSize.max : MainAxisSize.min;

  final FocusNode _focusNode = FocusNode();

  final TextStyle displayNameStyle = const TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, color: Color(primaryGrey));

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConfirmReceiptCubit, ConfirmReceiptState>(
      listener: (context, state) async {
        if (state is ConfirmReceiptSuccess) {
          receiptsToShare.addAll(List.from(state.excelReceipts));
          return;
        }

        if (state is ConfirmReceiptEmpty) {
          if (!mounted) return;
          Navigator.of(context).pop();
          _showEmptySnackBar(context);
          return;
        }
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(primaryDarkBlue),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: titleMainAxisSize,
              children: const [
                Text('Confirm receipt prices'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share),
                onPressed: () async {
                  await _handleExcelSharing();
                },
              ),
            ],
          ),
          body: BlocBuilder<ConfirmReceiptCubit, ConfirmReceiptState>(
              builder: (context, state) {

            switch (state) {
              case ConfirmReceiptInitial() || ConfirmReceiptLoading():
                return const Center(child: CircularProgressIndicator());
              case ConfirmReceiptEmpty():
                return const SizedBox.shrink();
              case ConfirmReceiptError():
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
              case ConfirmReceiptSuccess():
               _animationController.forward(from: 0.0);
                return FadeTransition(
                  opacity: _animationController,
                  child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.excelReceipts.length,
                      itemBuilder: (context, index) {
                        final receipt = state.excelReceipts[index];
                        final displayName = receipt.name.length > 25
                            ? "${receipt.name.substring(0, 25)}..."
                            : receipt.name.split('.').first;
                        return Container(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                    SlidingImageTransitionRoute(
                                        receipt: receipt));
                            },
                            key: UniqueKey(),
                            leading: SizedBox(
                              height: 100,
                              width: 50,
                              child: ClipRRect(
                                // square image corners
                                borderRadius:
                                    const BorderRadius.all(Radius.zero),
                                child: Image.file(
                                  File(receipt.localPath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(displayName,
                                style: displayNameStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            subtitle: Form(
                              key: UniqueKey(),
                              child: TextFormField(
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                        borderSide: const BorderSide(
                                            color: Color(primaryDarkBlue),
                                            width: 2.0))),
                                focusNode: _focusNode.enclosingScope,
                                initialValue: receipt.price,
                                keyboardType: TextInputType.text,
                                onChanged: (newPrice) {
                                  if (newPrice != receipt.price) {
                                      receipt.price = newPrice;
                                      receiptsToShare[index] = receipt;
                                      print(
                                          '${receiptsToShare[index].name}, ${receiptsToShare[index].price}');
                                  }
                                },
                              ),
                            ),
                          ),
                        );
                      }),
                );
            }
          })),
    );
  }
}
