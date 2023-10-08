import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: switchTabfadeDuration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
