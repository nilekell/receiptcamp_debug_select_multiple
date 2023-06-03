import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
        color: Colors.blue,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home),
              color: Colors.white),
            IconButton(
              icon: const Icon(Icons.upload_file),
              color: Colors.white,
              onPressed: () {}
            ),
            IconButton(
              onPressed: () {}, 
              icon: const Icon(Icons.folder),
              color: Colors.white,)
          ],
        ));
  }
}
