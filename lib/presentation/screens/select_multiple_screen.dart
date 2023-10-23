// defining a custom route class to animate transition
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_element, prefer_final_fields, unused_field, must_be_immutable
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/logic/cubits/select_multple/select_multiple_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

class SlidingSelectMultipleTransitionRoute extends PageRouteBuilder {
  SlidingSelectMultipleTransitionRoute({required ListItem item})
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

class ListItem {
  final String id;
  final Object item;

  ListItem({required this.item}) :
  id = Utility.generateUid();
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

  List<Object> allItems = <Object>[];

  List<Object> currentlySelectedItems = <Object>[];

  List<Folder> foldersThatCanBeMovedTo = <Folder>[];

  bool _moveActionEnabled = true;
  bool _deleteActionEnabled = true;
  bool allSelected = false;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    setState(() {
      currentlySelectedItems.add(widget.initiallySelectedItem);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  void _getFoldersThatCanBeMovedTo(List<Folder> currentlySelectedFolders) async {}

  void _showMoveMultipleDialog() async {}

  void _showDeleteMultipleDialog() {}

  void addItem(Object item) {
    currentlySelectedItems.add(item);
    print('added ${item.runtimeType}');
    print('num in currentlySelectedItems: ${currentlySelectedItems.length}');
  }

  void removeItem(Object item) {
    allSelected = false;

    if (item is Receipt) {
      currentlySelectedItems.removeWhere((element) => (element as Receipt).id == item.id);
      print('removed ${item.name}');
    } else if (item is Folder) {
      currentlySelectedItems.removeWhere((element) => (element as Folder).id == item.id);
      print('removed ${item.name}');
    }

    print('num in currentlySelectedItems: ${currentlySelectedItems.length}');
  }

  void toggleItem(Object item, bool value) {
      if (allSelected) allSelected = false;
      if (!value) removeItem(item);
      if (value) addItem(item);
  }

  void _toggleSelectAll() {
    setState(() {
      print('allSelected before toggle: $allSelected');
      if (!allSelected) {
        currentlySelectedItems = allItems;
        print('allItems assigned to currentlySelectedItems');
      } else if (allSelected) {
        for (final item in currentlySelectedItems) {
          removeItem(item);
        }
      }

      allSelected = !allSelected;
      print('allSelected after toggle: $allSelected');
    });
  }

  Widget _buildItem(Object item) {
    if (item is Receipt) {
      if (item is ReceiptWithSize) {
        return SizedBox(
            height: 60,
            child: ReceiptCheckboxListTile(
              receipt: item,
              withSize: true,
              isSelected: allSelected || currentlySelectedItems.contains(item),
              onChanged: (newValue) {
                toggleItem(item, newValue!);
              },
            ));
      }
      if (item is ReceiptWithPrice) {
        return SizedBox(
            height: 60,
            child: ReceiptCheckboxListTile(
              receipt: item,
              isSelected: allSelected || currentlySelectedItems.contains(item),
              price: item.priceString,
              onChanged: (newValue) {
                toggleItem(item, newValue!);
              },
            ));
      } else {
        return SizedBox(
            height: 60,
            child: ReceiptCheckboxListTile(
              receipt: item,
              isSelected: allSelected || currentlySelectedItems.contains(item),
              onChanged: (newValue) {
                toggleItem(item, newValue!);
              },
            ));
      }
    } else if (item is Folder) {
      if (item is FolderWithSize) {
        return SizedBox(
            height: 60,
            child: FolderCheckboxListTile(
              folder: item,
              storageSize: item.storageSize,
              isSelected: allSelected || currentlySelectedItems.contains(item),
              onChanged: (newValue) {
                toggleItem(item, newValue!);
              },
            ));
      }
      if (item is FolderWithPrice) {
        return SizedBox(
            height: 60,
            child: FolderCheckboxListTile(
              folder: item,
              price: item.price,
              isSelected: allSelected || currentlySelectedItems.contains(item),
              onChanged: (newValue) {
                toggleItem(item, newValue!);
              },
            ));
      } else {
        return SizedBox(
            height: 60,
            child: FolderCheckboxListTile(
              folder: item,
              isSelected: allSelected || currentlySelectedItems.contains(item),
              onChanged: (newValue) {
                toggleItem(item, newValue!);
              },
            ));
      }
    } else {
      return const ListTile(title: Text('Unknown file type'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SelectMultipleCubit, SelectMultipleState>(
      listener: (context, state) {
        if (state is SelectMultipleActivated) {
          allItems = state.items;
          print('allItems init with: $allItems');
          print('currentlySelectedItems init with $currentlySelectedItems');
        }
      },
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.close, size: 26,),
                onPressed: () => Navigator.of(context).pop()),
            backgroundColor: const Color(primaryDarkBlue),
            actions: [
             // select all
             IconButton(onPressed: _toggleSelectAll, icon: Icon(Icons.select_all)),
             // delete selected items
             IconButton(onPressed: _showDeleteMultipleDialog, icon: Icon(Icons.delete)),
             // move selected items
             IconButton(onPressed: _showMoveMultipleDialog, icon: Icon(Icons.drive_file_move))
            ],
          ),
          body: BlocBuilder<SelectMultipleCubit, SelectMultipleState>(
              builder: (context, state) {
            switch (state) {
              case SelectMultipleInitial() || SelectMultipleLoading():
                return const Center(child: CircularProgressIndicator());
              case SelectMultipleError():
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: const Text(
                            'Uh oh, an unexpected error occured. Please go back and/or report the error', textAlign: TextAlign.center, textScaleFactor: 1.2,),
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(primaryDarkBlue))),
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

class FolderCheckboxListTile extends StatefulWidget {
  final Folder folder;
  bool isSelected;
  final ValueChanged<bool?> onChanged; 
  final String displayName;
  final String displayDate;
  final String displaySize;
  final String displayPrice;
  final String? price;
  final int? storageSize;
   // Optional storageSize parameter used to determine whether to show displaySize in subtitle & FolderListTileVisual

  FolderCheckboxListTile({Key? key, required this.folder, required this.onChanged, this.isSelected = false, this.storageSize, this.price})
      : displayName = folder.name.length > 25
            ? "${folder.name.substring(0, 25)}..."
            : folder.name,
        displayDate = Utility.formatDisplayDateFromDateTime(
            Utility.formatDateTimeFromUnixTimestamp(folder.lastModified)),
        displaySize =
            storageSize != null ? Utility.bytesToSizeString(storageSize) : '',
        displayPrice = price ?? '',
        super(key: key);

  @override
  State<FolderCheckboxListTile> createState() => _FolderCheckboxListTileState();
}

class _FolderCheckboxListTileState extends State<FolderCheckboxListTile> {
  final TextStyle displayNameStyle = const TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, color: Color(primaryGrey));

  final TextStyle displayDateStyle =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
      

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: CheckboxListTile(
        value: widget.isSelected,
        onChanged: (value) {
          setState(() {
              widget.isSelected = !widget.isSelected;
              widget.onChanged(widget.isSelected);
            });
        },
        subtitle: Text(
          widget.displaySize.isNotEmpty ? widget.displaySize : widget.displayPrice != '' ? widget.displayPrice : 'Modified ${widget.displayDate}',
          style: displayDateStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        secondary: const Icon(
          Icons.folder,
          size: 50,
        ),
        title: Text(
          widget.displayName,
          style: displayNameStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class ReceiptCheckboxListTile extends StatefulWidget {
  final Receipt receipt;
  final bool isSelected;
  final ValueChanged<bool?> onChanged; 
  final String displayName;
  final String displayDate;
  final String displaySize;
  final String price;
  final bool withSize;

  ReceiptCheckboxListTile({Key? key, required this.receipt, required this.onChanged, this.isSelected = false, this.withSize = false, this.price = ''})
      // displayName is the file name without the file extension and is cut off when the receipt name
      // is > 25 chars or would require 2 lines to be shown completely
      : displayName = receipt.name.length > 25
            ? "${receipt.name.substring(0, 25)}..."
            : receipt.name.split('.').first,
        displayDate = Utility.formatDisplayDateFromDateTime(
            Utility.formatDateTimeFromUnixTimestamp(receipt.lastModified)),
        displaySize = Utility.bytesToSizeString(receipt.storageSize),
          
        super(key: key);

  @override
  State<ReceiptCheckboxListTile> createState() => _ReceiptCheckboxListTileState();
}

class _ReceiptCheckboxListTileState extends State<ReceiptCheckboxListTile> {
  final TextStyle displayNameStyle = const TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, color: Color(primaryGrey));

  final TextStyle displayDateStyle =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: CheckboxListTile(
          value: isSelected,
          onChanged: (value) {
            setState(() {
              isSelected = !isSelected;
              widget.onChanged(isSelected);
            });
          },
            secondary: SizedBox(
              height: 50,
              width: 50,
              child: ClipRRect(
                // square image corners
                borderRadius: const BorderRadius.all(Radius.zero),
                child: Image.file(
                  File(widget.receipt.localPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            subtitle: Text(
              widget.withSize
                ? widget.displaySize
                : widget.price != '' ? widget.price : 'Modified ${widget.displayDate}',
              style: displayDateStyle,
            ),
            title: Text(widget.displayName,
                style: displayNameStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis)));
  }
}