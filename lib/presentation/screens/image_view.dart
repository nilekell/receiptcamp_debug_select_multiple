// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/presentation/ui/image_view/image_sheet.dart';

// defining a custom route class to animate transition to ImageViewScreen
class SlidingImageTransitionRoute extends PageRouteBuilder {
  final Receipt receipt;

  SlidingImageTransitionRoute({
    required this.receipt,
  }) : super(
          opaque: false,
          // Define the page to be built
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return Dismissible(
              onDismissed: (direction) {
                Navigator.of(context).pop();
              },
              key: UniqueKey(),
              direction: DismissDirection.down,
              child: ImageViewScreen(
                imageProvider: Image.file(File(receipt.localPath)).image,
                receipt: receipt,
              ),
            );
          },
          // Define the transitions builder to handle animations
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            // Define the starting and ending points of the animation
            const begin = Offset(0.0, 1.0); // Starting point (off-screen below)
            const end = Offset.zero; // Ending point (on-screen)

            // The beginning and ending Offset values define the path along which the
            // ImageViewScreen will move. The 'begin' Offset (0.0, 1.0) starts the screen
            // one full height below the visible area, and the 'end' Offset (0.0, 0.0)
            // ends the screen at its final position, fully visible.

            // Define the curve of the animation
            const curve = Curves.easeInOut;

            // The curve defines the rate of change of the animation over time, affecting
            // how the ImageViewScreen accelerates and decelerates as it moves onto the
            // screen. The 'easeInOut' curve starts slow, speeds up, and then slows down
            // again, creating a smooth transition.

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

class ImageViewScreen extends StatefulWidget {
  final ImageProvider imageProvider;
  final Receipt receipt;

  const ImageViewScreen(
      {Key? key, required this.imageProvider, required this.receipt})
      : super(key: key);

  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  bool _isAppBarInitiallyVisible = true;

  @override
  void initState() {
    super.initState();
    // hiding top and bottom platform overlays when screen is displayed
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  void dispose() {
    // re-showing top and bottom platform overlays when screen is closed
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  void _toggleAppBar() {
    setState(() {
      _isAppBarInitiallyVisible = !_isAppBarInitiallyVisible;
    });
  }

  void _hideAppBar() {
    setState(() {
      _isAppBarInitiallyVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
        GestureDetector(
          onVerticalDragEnd: (details) {
            print(details.primaryVelocity);
            if (details.primaryVelocity! >= 10.0) {
              _hideAppBar();
              Navigator.of(context).pop();
            }
          },
          onTap: _toggleAppBar,
          onDoubleTap: _toggleAppBar,
          child: PhotoView(
            scaleStateChangedCallback: (value) {
              _toggleAppBar();
            },
            maxScale: PhotoViewComputedScale.contained * 3,
            minScale: PhotoViewComputedScale.contained * 0.8,
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            imageProvider: widget.imageProvider,
            loadingBuilder: (context, progress) => Center(
              child: CircularProgressIndicator(
                value: progress?.expectedTotalBytes != null
                    ? progress!.cumulativeBytesLoaded /
                        (progress.expectedTotalBytes ?? 1)
                    : null,
              ),
            ),
          ),
        ),
        ImageViewAppBar(
          isAppBarVisible: _isAppBarInitiallyVisible,
          receipt: widget.receipt,
        ),
      ]),
    );
  }
}

class ImageViewAppBar extends StatelessWidget {
  const ImageViewAppBar(
      {super.key, required bool isAppBarVisible, required this.receipt})
      : _isAppBarVisible = isAppBarVisible;

  final Receipt receipt;
  final bool _isAppBarVisible;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      curve: Curves.easeOut,
      top: _isAppBarVisible ? 0 : -100,
      left: 0,
      right: 0,
      duration: const Duration(milliseconds: 200),
      child: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.5),
        title: Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Text(
            receipt.name,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Transform.translate(
              offset: const Offset(8.0, 10.0),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 26.0,
              ),
            )),
        actions: [
          IconButton(
            onPressed: () {
              showImageOptions(context, receipt);
            },
            icon: Transform.translate(
              offset: const Offset(-8.0, 10.0),
              child: const Icon(
                Icons.more_horiz_sharp,
                color: Colors.white,
                size: 26.0,
              ),
            )
          )
        ],
      ),
    );
  }
}
