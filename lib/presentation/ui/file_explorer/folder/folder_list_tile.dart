import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/logic/cubits/file_system/file_system_cubit.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/presentation/ui/file_explorer/folder/folder_sheet.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';


class FolderListTile extends StatelessWidget {
  final Folder folder;
  final String displayName;
  final String displayDate;
  final String displaySize;
  final String draggableName;
  final int? storageSize;
   // Optional storageSize parameter used to determine whether to show displaySize in subtitle & FolderListTileVisual

  FolderListTile({Key? key, required this.folder, this.storageSize})
      : displayName = folder.name.length > 25
            ? "${folder.name.substring(0, 25)}..."
            : folder.name,
        draggableName = folder.name.length > 10
            ? "${folder.name.substring(0, 10)}..."
            : folder.name,
        displayDate = Utility.formatDisplayDateFromDateTime(
            Utility.formatDateTimeFromUnixTimestamp(folder.lastModified)),
        displaySize =
            storageSize != null ? Utility.bytesToSizeString(storageSize) : '',
        super(key: key);

  final TextStyle displayNameStyle = const TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, color: Color(primaryGrey));
  final TextStyle displayDateStyle =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

  @override
  Widget build(BuildContext context) {
    return DragTarget<Object>(
      onWillAccept: (data) {
        if (data is Receipt) {
          return true;
        } else if (data is Folder) {
          return data.id != folder.id;
        } else {
          return false;
        }
      },
      onAccept: (data) {
        if (data is Receipt) {
          context.read<FolderViewCubit>().moveReceipt(data, folder.id);
          return;
        } else if (data is Folder) {
          context.read<FolderViewCubit>().moveFolder(data, folder.id);
          return;
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          color: candidateData.isNotEmpty ? Colors.grey : Colors.transparent,
          child: LongPressDraggable<Folder>(
            dragAnchorStrategy: (draggable, context, position) {
              return const Offset(50, 50);
            },
            data: folder,
            childWhenDragging: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.srcIn,
              ),
              child: FolderListTileVisual(folder: folder, storageSize: storageSize),
            ),
            feedback: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Opacity(
                    opacity: 0.7,
                    child: Icon(
                      Icons.folder,
                      size: 100,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: Text(
                      draggableName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: ListTile(
                subtitle: Text(
                  displaySize.isNotEmpty ? displaySize : 'Modified $displayDate',
                  style: displayDateStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                leading: const Icon(
                  Icons.folder,
                  size: 50,
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Color(primaryGrey),
                    size: 30,
                  ),
                  onPressed: () {
                    showFolderOptions(
                        context, context.read<FolderViewCubit>(), folder);
                  },
                ),
                onTap: () {
                  context.read<FileSystemCubit>().selectFolder(folder.id);
                },
                title: Text(
                  displayName,
                  style: displayNameStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// placeholder widget while draggable is active
class FolderListTileVisual extends StatelessWidget {
  final Folder folder;
  final String displayName;
  final String displayDate;
  final String displaySize;
  final int? storageSize;

  final TextStyle displayNameStyle = const TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, color: Color(primaryGrey));
  
  final TextStyle subTextStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

  FolderListTileVisual({Key? key, required this.folder, this.storageSize})
      : displayName = folder.name.length > 25

            ? "${folder.name.substring(0, 25)}..."
            : folder.name,
        displayDate = Utility.formatDisplayDateFromDateTime(
            Utility.formatDateTimeFromUnixTimestamp(folder.lastModified)),
        displaySize =
            storageSize != null ? Utility.bytesToSizeString(storageSize) : '',
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: ListTile(
        subtitle: Text(
          storageSize != null ? displaySize : 'Modified $displayDate',  // Ternary operator to decide displayed text
          style: subTextStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: const Icon(
          Icons.folder,
          size: 50,
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.more_vert,
            color: Color(primaryGrey),
            size: 30,
          ),
          onPressed: () {
            return;
          },
        ),
        onTap: () {
          return;
        },
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
