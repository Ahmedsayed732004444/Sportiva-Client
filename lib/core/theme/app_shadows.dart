import 'package:flutter/material.dart';

abstract final class AppShadows {
  // X 0, Y 0, blur 4, #000000 at 25%.
  static const drop = [BoxShadow(color: Color(0x40000000), blurRadius: 4)];
}
