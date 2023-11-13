import 'package:flutter/material.dart';
import 'dart:io' show Platform;
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  // aligning title text in row depending on platform
  final titleMainAxisSize =
      Platform.isAndroid ? MainAxisSize.max : MainAxisSize.min;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Transform.scale(
              scale: 1.5, // Adjust the scale as needed
              child: Image.asset(
                'assets/top_gradient.png',
                fit: BoxFit.fill, // Make sure the image covers the entire space
              ),
            ),
          );
        },
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: titleMainAxisSize,
        children: const <Widget>[
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
    );
  }
}
