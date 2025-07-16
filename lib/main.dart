import 'package:flutter/material.dart';
import 'package:token_studio_demo/styles/tokens.style.g.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: DesignTokens.background,
        body: Center(
          child: Text(
            'hello world',
            style: TextStyle(color: DesignTokens.onBackground),
          ),
        ),
      ),
    );
  }
}