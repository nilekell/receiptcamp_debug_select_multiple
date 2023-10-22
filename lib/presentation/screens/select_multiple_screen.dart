// defining a custom route class to animate transition
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_element, prefer_final_fields, unused_field
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/logic/cubits/select_multple/select_multiple_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

class SlidingSelectMultipleTransitionRoute extends PageRouteBuilder {
  SlidingSelectMultipleTransitionRoute({required Object item})
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
              child: SelectMultipleView(
                initiallySelectedItem: item,
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
                      SelectMultipleCubit()..init(item),
                  child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

class SelectMultipleView extends StatefulWidget {
  const SelectMultipleView({Key? key, required this.initiallySelectedItem})
      : super(key: key);

  final Object initiallySelectedItem;

  @override
  State<SelectMultipleView> createState() =>
      _SelectMultipleViewState();
}

class _SelectMultipleViewState extends State<SelectMultipleView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  List<Object> currentlySelectedItems = <Object>[];

  List<Folder> foldersThatCanBeMovedTo = <Folder>[];

  bool _moveActionEnabled = true;
  bool _deleteActionEnabled = true;

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

  void _getFoldersThatCanBeMovedTo(List<Folder> currentlySelectedFolders) async {}

  void _showMoveMultipleDialog(List<Folder> destinationFolders) {}

  void _showDeleteMultipleDialog() {}

  void _toggleSelectAll() {
    
  }

  Widget _buildItem(Object item) {
    if (item is Receipt) {
      if (item is ReceiptWithSize) {
        return SizedBox(
            height: 60,
            child: ReceiptCheckboxListTile(
              receipt: item,
              withSize: true,
            ));
      } 
      if (item is ReceiptWithPrice) {
        return SizedBox(
            height: 60,
            child: ReceiptCheckboxListTile(
              receipt: item,
              price: item.priceString,
            ));
      }
      else {
        return SizedBox(
            height: 60,
            child: ReceiptCheckboxListTile(receipt: item));
      }
    } else if (item is Folder) {
      if (item is FolderWithSize) {
        return SizedBox(
            height: 60,
            child: FolderCheckboxListTile(
              folder: item,
              storageSize: item.storageSize,
            ));
      } 
      if (item is FolderWithPrice) {
        return SizedBox(
            height: 60,
            child: FolderCheckboxListTile(
              folder: item,
              price: item.price,
            ));
      }
      else {
        return SizedBox(
            height: 60,
            child: FolderCheckboxListTile(folder: item));
      }
    } else {
      return const ListTile(
          title: Text('Unknown file type'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SelectMultipleCubit, SelectMultipleState>(
      listener: (context, state) {
      },
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.close, size: 26,),
                onPressed: () => Navigator.of(context).pop()),
            backgroundColor: const Color(primaryDarkBlue),
            actions: [
             // select all
             IconButton(onPressed: () {}, icon: Icon(Icons.select_all)),
             // delete selected items
             IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
             // move selected items
             IconButton(onPressed: () {}, icon: Icon(Icons.drive_file_move))
            ],
          ),
          body: BlocBuilder<SelectMultipleCubit, SelectMultipleState>(
              builder: (context, state) {
            switch (state) {
              case SelectMultipleInitial() || SelectMultipleLoading():
                return const Center(child: CircularProgressIndicator());
              case SelectMultipleError():
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
              case SelectMultipleActivated():
                _animationController.forward(from: 0.0);
                return FadeTransition(
                  opacity: _animationController,
                  child: Column(
                    children: [
                      Expanded(
                        child: CustomScrollView(
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      slivers: <Widget>[
                                        SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: state.items.length,
                              (context, index) {
                                var item = state.items[index];
                                return _buildItem(item);
                              },
                            ),
                          )
                                      ],
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

class FolderCheckboxListTile extends StatelessWidget {
  final Folder folder;
  final String displayName;
  final String displayDate;
  final String displaySize;
  final String displayPrice;
  final String? price;
  final int? storageSize;
   // Optional storageSize parameter used to determine whether to show displaySize in subtitle & FolderListTileVisual

  FolderCheckboxListTile({Key? key, required this.folder, this.storageSize, this.price})
      : displayName = folder.name.length > 25
            ? "${folder.name.substring(0, 25)}..."
            : folder.name,
        displayDate = Utility.formatDisplayDateFromDateTime(
            Utility.formatDateTimeFromUnixTimestamp(folder.lastModified)),
        displaySize =
            storageSize != null ? Utility.bytesToSizeString(storageSize) : '',
        displayPrice = price ?? '',
        super(key: key);

  final TextStyle displayNameStyle = const TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, color: Color(primaryGrey));
  final TextStyle displayDateStyle =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: CheckboxListTile(
        value: false,
        onChanged: (value) {
          
        },
        subtitle: Text(
          displaySize.isNotEmpty ? displaySize : displayPrice != '' ? displayPrice : 'Modified $displayDate',
          style: displayDateStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        secondary: const Icon(
          Icons.folder,
          size: 50,
        ),
        title: Text(
          displayName,
          style: displayNameStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class ReceiptCheckboxListTile extends StatelessWidget {
  final Receipt receipt;
  final String displayName;
  final String displayDate;
  final String displaySize;
  final String price;
  final bool withSize;

  ReceiptCheckboxListTile({Key? key, required this.receipt, this.withSize = false, this.price = ''})
      // displayName is the file name without the file extension and is cut off when the receipt name
      // is > 25 chars or would require 2 lines to be shown completely
      : displayName = receipt.name.length > 25
            ? "${receipt.name.substring(0, 25)}..."
            : receipt.name.split('.').first,
        displayDate = Utility.formatDisplayDateFromDateTime(
            Utility.formatDateTimeFromUnixTimestamp(receipt.lastModified)),
        displaySize = Utility.bytesToSizeString(receipt.storageSize),
          
        super(key: key);

  final TextStyle displayNameStyle = const TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, color: Color(primaryGrey));
  final TextStyle displayDateStyle =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: CheckboxListTile(
          value: false,
          onChanged: (value) {
            
          },
            secondary: SizedBox(
              height: 50,
              width: 50,
              child: ClipRRect(
                // square image corners
                borderRadius: const BorderRadius.all(Radius.zero),
                child: Image.file(
                  File(receipt.localPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            subtitle: Text(
              withSize
                ? displaySize
                : price != '' ? price : 'Modified $displayDate',
              style: displayDateStyle,
            ),
            title: Text(displayName,
                style: displayNameStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis)));
  }
}