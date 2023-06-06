// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/blocs/explorer/explorer_bloc.dart';
import 'package:receiptcamp/logic/blocs/home/home_bloc.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
        return BottomAppBar(
            color: Colors.blue,
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: () {
                      context.read<ExplorerBloc>().add(ExplorerNavigateToHomeEvent());
                    },
                    icon: const Icon(Icons.home),
                    color: Colors.white),
                IconButton(
                  onPressed: () async {
                    context.read<HomeBloc>().add(HomeNavigateToFileExplorerEvent());
                  },
                  icon: const Icon(Icons.folder),
                  color: Colors.white,
                )
              ],
            ));
  }
}
