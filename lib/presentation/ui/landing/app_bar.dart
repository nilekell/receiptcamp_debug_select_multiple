import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/blocs/search/search_bloc.dart';
import 'package:receiptcamp/presentation/ui/search/search.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(primaryDarkBlue),
              Color(primaryLightBlue),
            ],
            stops: [0.0, 0.75],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      title: const Row(
        mainAxisSize: MainAxisSize.min, // centers title by reducing width of row
        children: <Widget>[
          Text(
            'Receipt',
            style: TextStyle(
              fontWeight: FontWeight.bold, // Medium weight
              color: Colors.white,
              fontSize: 27,
            ),
          ),
          Text(
            'Camp',
            style: TextStyle(
              fontWeight: FontWeight.normal, // Regular weight
              color: Colors.white,
              fontSize: 27,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            showSearch(
                context: context,
                delegate: CustomSearchDelegate(
                    searchBloc: context.read<SearchBloc>()));
          },
          icon: const Icon(Icons.search),
        )
      ],
    );
  }
}
