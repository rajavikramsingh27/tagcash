import 'package:flutter/material.dart';
import 'package:tagcash/utils/create_material_color.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primarySwatch: createMaterialColor(Color(0xFFe44933)),
    primaryColor: Color(0xFFe44933),
    textTheme: TextTheme(
      subtitle1: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      ),
    ),
    pageTransitionsTheme: PageTransitionsTheme(builders: {
      TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
    }),
  );

  static final ThemeData darkTheme = ThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.dark,
    primarySwatch: createMaterialColor(Color(0xFFe44933)),
    primaryColor: Color(0xFFe44933),
    accentColor: Color(0xFFe44933),
    scaffoldBackgroundColor: Colors.black,
    textTheme: TextTheme(
      subtitle1: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      ),
    ),
    pageTransitionsTheme: PageTransitionsTheme(builders: {
      TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
    }),
  );
}
