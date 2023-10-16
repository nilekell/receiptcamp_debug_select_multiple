// ignore_for_file: prefer_final_fields, unused_field
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:receiptcamp/data/services/directory_path_provider.dart';
import 'package:receiptcamp/logic/blocs/home/home_bloc.dart';
import 'package:receiptcamp/data/services/preferences.dart';
import 'package:receiptcamp/logic/cubits/file_system/file_system_cubit.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/logic/cubits/landing/landing_cubit.dart';
import 'package:receiptcamp/presentation/screens/file_explorer.dart';
import 'package:receiptcamp/presentation/screens/home.dart';
import 'package:receiptcamp/presentation/ui/landing/app_bar.dart';
import 'package:receiptcamp/presentation/ui/landing/drawer.dart';
import 'package:receiptcamp/presentation/ui/landing/nav_bar.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  StreamSubscription? _intentActiveDataStreamSubscription;
  Future<List<SharedMediaFile>>?  _intentInactiveDataList;
  List<SharedMediaFile> _sharedMediaFiles = [];
  List<SharedMediaFile> _inactiveSharedMediaFiles = [];
  List<File> _sharedFiles = [];
  final RegExp fileExtensionRegExp = RegExp(r'\.(jpe?g|png)$', caseSensitive: false);


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: switchTabfadeDuration,
    );

    // For sharing images coming from outside the app while the app is in the memory
    _intentActiveDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) async {
      _sharedMediaFiles = value;
      if (_sharedMediaFiles.isEmpty) return;

      File tempImage;

      for (final file in _sharedMediaFiles) {
        File sharedImage = File(file.path);
        if (fileExtensionRegExp.hasMatch(extension(sharedImage.path))) {
          String newTempPath =
              '${DirectoryPathProvider.instance.tempDirPath}/${(basename(sharedImage.path).toLowerCase())}';
          tempImage = await sharedImage.copy(newTempPath);
          sharedImage.delete();
          _sharedFiles.add(tempImage);
          print(tempImage.path);
          if (tempImage.existsSync()) tempImage.delete();
        } else {
          print('skipping file: ${basename(sharedImage.path)}');
          continue;
        }
      }

      _sharedMediaFiles.clear();
      _sharedFiles.clear();
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    _intentInactiveDataList = ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      return value;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _intentActiveDataStreamSubscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingCubit, int>(
      builder: (context, state) {
        _controller.forward(from: 0.0); // Trigger the animation
        return Scaffold(
          drawer: const AppDrawer(),
          appBar: HomeAppBar(),
          body: FadeTransition(
            opacity: _controller,
            child: IndexedStack(
              index: state,
              children: [
                const Home(),
                MultiBlocProvider(
                  providers: [
                    BlocProvider<FileSystemCubit>(
                      create: (context) => FileSystemCubit()..initializeFileSystemCubit(),
                    ),
                    BlocProvider(
                      create: (context) => FolderViewCubit(homeBloc: context.read<HomeBloc>(), prefs: PreferencesService.instance)..initFolderView(),
                    ),
                  ],
                  child: const FileExplorer(),
                ),
              ],
            ),
          ),
          bottomNavigationBar: bottomNavigationBar(state, context),
        );
      },
    );
  }
}
