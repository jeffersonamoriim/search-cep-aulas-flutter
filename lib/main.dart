import 'package:flutter/material.dart';
import 'package:search_cep/views/home_page.dart';
import 'package:search_cep/services/custom_theme.dart';
import 'package:search_cep/models/themes.dart';


void main() {
  runApp(
    CustomTheme(
      initialThemeKey: MyThemeKeys.LIGHT,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Search CEP',
      theme: CustomTheme.of(context),
      home: HomePage(),
    );
  }
}