import 'package:brand_names/src/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Band Names',
      initialRoute: 'home',
      routes: {
        'home': (_) => HomePage(),
      },
    );
  }
}
