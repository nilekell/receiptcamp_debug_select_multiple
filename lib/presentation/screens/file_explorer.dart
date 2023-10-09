// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/data_constants.dart';
import 'package:receiptcamp/logic/cubits/file_system/file_system_cubit.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/presentation/screens/error_view.dart';
import 'package:receiptcamp/presentation/ui/file_explorer/folder/folder_list_tile.dart';
import 'package:receiptcamp/presentation/ui/file_explorer/order_sheet.dart';
import 'package:receiptcamp/presentation/ui/file_explorer/receipt/receipt_list_tile.dart';
import 'package:receiptcamp/presentation/ui/file_explorer/snackbar_utility.dart';
import 'package:receiptcamp/presentation/ui/file_explorer/upload_sheet.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

class FileExplorer extends StatefulWidget {
  const FileExplorer({super.key});

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  final ValueNotifier<bool> _showUploadButtonNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      // Hide the upload button when user scroll down
      if (_showUploadButtonNotifier.value) _showUploadButtonNotifier.value = false;
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      // Show the upload button when user scroll up
      if (!_showUploadButtonNotifier.value) _showUploadButtonNotifier.value = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<FileSystemCubit, FileSystemCubitState>(
          listener: (context, state) {
        switch (state) {
          case FileSystemCubitFolderInformationSuccess():
          // listening to state here so RefreshableFolderView can be built with the new folder contents, whenever
          // a folder is navigated to
            print('FileExplorer: fetchFiles for ${state.folder.name}');
            context
                .read<FolderViewCubit>()
                .fetchFilesInFolderSortedBy(state.folder.id);
          default:
            print('FileExplorer builder state: ${state.toString()}');
        }
      }, builder: ((context, state) {
        switch (state) {
          case FileSystemCubitInitial() || FileSystemCubitLoading():
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: CircularProgressIndicator()),
              ],
            );
          case FileSystemCubitFolderInformationSuccess():
            _animationController.forward(from: 0.0);
            return FadeTransition(
              opacity: _animationController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        children: [
                          BackButton(
                            previousFolderId: state.folder.parentId,
                            currentFolderId: state.folder.id,
                            visible: state.folder.id != rootFolderId,
                          ),
                        ],
                      ),
                      FolderName(
                        name: state.folder.id != rootFolderId
                            ? state.folder.name
                            : 'Expenses',
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  const Divider(
                    thickness: 2,
                    height: 1,
                    indent: 25,
                    endIndent: 25,
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        RefreshableFolderView(
                            scrollController: _scrollController),
                        ValueListenableBuilder<bool>(
                          valueListenable: _showUploadButtonNotifier,
                          child: Positioned(
                                right: 28,
                                bottom: 28,
                                child: UploadButton(currentFolder: state.folder),
                              ),
                          builder: (context, showUploadButton, child) {
                            if (showUploadButton) {
                              return child!;
                            } else {
                              return const SizedBox.shrink(); // Return an empty widget that takes up no space
                            }
                          },
                          )
                      ],
                    ),
                  ),
                ],
              ),
            );
          case FileSystemCubitError():
            print(
                'FileSystemCubitError with state: ${state.runtimeType.toString()}');
            return const ErrorView();
          default:
            print(
                'FileExplorer BlocBuilder - Unaccounted for state: ${state.runtimeType.toString()}');
            return Container();
        }
      })),
    );
  }
}

class FolderName extends StatelessWidget {
  final String name;
  FolderName({
    super.key,
    required this.name,
  }) : displayName = name.length > 20
            ? "${name.substring(0, 20)}...".split('.').first
            : name.split('.').first;

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 5),
      child: Text(
        displayName,
        style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: Color(primaryGrey)),
      ),
    );
  }
}

class BackButton extends StatelessWidget {
  final String previousFolderId;
  final String currentFolderId;
  final bool visible;

  const BackButton(
      {super.key,
      required this.previousFolderId,
      required this.currentFolderId,
      required this.visible});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: visible,
      child: Transform.translate(
        offset: const Offset(10, 6),
        child: IconButton(
            onPressed: () {
              context.read<FileSystemCubit>().navigateBack(previousFolderId);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(primaryDarkBlue),
              size: 26.0,
            )),
      ),
    );
  }
}

class SortOption extends StatelessWidget {
  final Widget displayWidget;
  final String currentColumn;
  final String currentOrder;
  final String folderId;
  final FolderViewCubit cubit;

  const SortOption({
    required this.displayWidget,
    required this.currentColumn,
    required this.currentOrder,
    required this.folderId,
    required this.cubit,
    Key? key,
  }) : super(key: key);

  final sortOptionPadding = const EdgeInsets.only(top: 12.0, left: 30.0);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(4.0),
        onTap: () {
          showOrderOptions(context, cubit, currentOrder, currentColumn, folderId);
        },
        child: Padding(
          padding: sortOptionPadding,
          child: displayWidget,
        ),
      ),
    );
  }
}

class OrderIcon extends Icon {
  const OrderIcon(String order, {super.key})
      : super(
            order == 'ASC'
                ? Icons.arrow_upward
                : order == 'DESC'
                    ? Icons.arrow_downward
                    : Icons.error,
            size: 18.0,
            color: const Color(primaryGrey));
}

Widget getSortDisplayWidget(String orderedBy, String order) {
  const sortTextStyle = TextStyle(
      fontSize: 16, color: Color(primaryGrey), fontWeight: FontWeight.w600);

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        () {
          switch (orderedBy) {
            case 'name':
              return 'Name';
            case 'storageSize':
              return 'Storage used';
            case 'lastModified':
              return 'Last modified';
            default:
              return 'name';
          }
        }(),
        style: sortTextStyle,
      ),
      OrderIcon(order),
    ],
  );
}

class RefreshableFolderView extends StatefulWidget {
  final ScrollController scrollController;

  const RefreshableFolderView({super.key, required this.scrollController});

  @override
  State<RefreshableFolderView> createState() => _RefreshableFolderViewState();
}

class _RefreshableFolderViewState extends State<RefreshableFolderView> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FolderViewCubit, FolderViewState>(
      listenWhen: (previous, current) => current is FolderViewActionState,
      listener: (context, state) {
        SnackBarUtility.showSnackBar(context, state as FolderViewActionState);
      },
      buildWhen: (previous, current) =>
          previous is! FolderViewActionState ||
          current is! FolderViewActionState,
      builder: (context, state) {
        switch (state) {
          case FolderViewInitial() || FolderViewLoading():
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: CircularProgressIndicator()),
              ],
            );
          case FolderViewLoadedSuccess():
            print(
                'RefreshableFolderView built with folder: ${state.folder.name}, ${state.orderedBy}, ${state.order}');
            return RefreshIndicator(
              onRefresh: () async {
                print('refreshing folder ${state.folder.name}');
                context
                    .read<FolderViewCubit>()
                    .fetchFilesInFolderSortedBy(state.folder.id);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: widget.scrollController,
                slivers: <Widget>[
                  state.files.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: SortOption(
                            displayWidget: getSortDisplayWidget(
                                state.orderedBy, state.order),
                            currentColumn: state.orderedBy,
                            currentOrder: state.order,
                            folderId: state.folder.id,
                            cubit: context.read<FolderViewCubit>(),
                          ),
                        )
                      : SliverToBoxAdapter(child: Container()),
                  state.files.isNotEmpty
                      ? SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              var item = state.files[index];
                              if (item is Receipt) {
                                if (item is ReceiptWithSize) {
                                  return SizedBox(
                                      height: 60,
                                      child: ReceiptListTile(
                                        receipt: item,
                                        withSize: true,
                                      ));
                                } else {
                                  return SizedBox(
                                      height: 60,
                                      child: ReceiptListTile(receipt: item));
                                }
                              } else if (item is Folder) {
                                if (item is FolderWithSize) {
                                  return SizedBox(
                                      height: 60,
                                      child: FolderListTile(
                                        folder: item,
                                        storageSize: item.storageSize,
                                      ));
                                } else {
                                  return SizedBox(
                                      height: 60,
                                      child: FolderListTile(folder: item));
                                }
                              } else {
                                return const ListTile(
                                    title: Text('Unknown file type'));
                              }
                            },
                            childCount: state.files
                                .length, // specifies the number of children this delegate will build
                          ),
                        )
                      : SliverFillRemaining(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 200,
                                width: 200,
                                child: Image.asset('assets/x2_retina_receipt_icon.png')),
                              const SizedBox(
                                height: 12,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text(
                                  'To add receipts, tap the + button below',
                                  style: TextStyle(
                                      color: Color(primaryGrey),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w100),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            );
          case FolderViewError():
            print(
                'FolderViewCubitError with state: ${state.runtimeType.toString()}');
            return const ErrorView();
          default:
            print(
                'RefreshableFolderView BlocBuilder - Unaccounted for state: ${state.runtimeType.toString()}');
            return Container();
        }
      },
    );
  }
}

class UploadButton extends StatelessWidget {
  final Folder currentFolder;

  const UploadButton({super.key, required this.currentFolder});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
      onPressed: () {
        showUploadOptions(
            context, context.read<FolderViewCubit>(), currentFolder);
      },
      child: Stack(alignment: Alignment.center, children: [
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                image: AssetImage('assets/circle_gradient.png')),
          ),
        ),
        const Icon(
          Icons.add,
          size: 70,
        )
      ]),
    );
  }
}
