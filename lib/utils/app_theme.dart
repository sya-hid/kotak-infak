import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  get darkTheme => ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.grey,
        brightness: Brightness.dark,
        textTheme: TTextTheme.darkTextTheme,
        appBarTheme: const AppBarTheme(),
        iconTheme: const IconThemeData(color: Colors.grey),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(),
        elevatedButtonTheme:
            ElevatedButtonThemeData(style: ElevatedButton.styleFrom()),
      );

  get lightTheme => ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: false,
        brightness: Brightness.light,
        textTheme: TTextTheme.lightTextTheme,
        appBarTheme: const AppBarTheme(),
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(),
        elevatedButtonTheme:
            ElevatedButtonThemeData(style: ElevatedButton.styleFrom()),
      );
}

class TTextTheme {
  static TextTheme lightTextTheme = TextTheme(
    displayMedium: GoogleFonts.montserrat(color: Colors.black87),
    titleSmall: GoogleFonts.poppins(color: Colors.deepPurple, fontSize: 24),
  );
  static TextTheme darkTextTheme = TextTheme(
    displayMedium: GoogleFonts.montserrat(color: Colors.white70),
    titleSmall: GoogleFonts.poppins(color: Colors.white60, fontSize: 24),
  );
}
