// ignore: dangling_library_doc_comments
/// This file will have a button widget that though has text and stuff but is just placed you can't seen it. because I'll just have the image in background on image this button will be stacked for functionality across all the screens.

import 'package:flutter/material.dart';

class TransparentButton extends StatelessWidget {
  final VoidCallback onTap;
  final double width;
  final double height;

  const TransparentButton({
    super.key,
    required this.onTap,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: height,
        // child: Text("herrrr"),
      ),
    );
  }
}