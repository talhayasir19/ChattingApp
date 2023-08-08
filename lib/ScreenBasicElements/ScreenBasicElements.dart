import 'package:flutter/material.dart';

late Size size;
late double toolBarHeight, screenWidth, screenHeight, topBarSize, bottomBarSize;

void initialize(BuildContext context) {
  size = MediaQuery.of(context).size;
  screenWidth = size.width;
  topBarSize = MediaQuery.of(context).padding.top;
  bottomBarSize = MediaQuery.of(context).padding.bottom;
  toolBarHeight = kToolbarHeight;
  screenHeight = size.height - bottomBarSize - toolBarHeight;
}
