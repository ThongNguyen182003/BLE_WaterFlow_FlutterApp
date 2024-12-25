import 'package:flutter/material.dart';
import 'screens/homepage.dart'; // Import HomePage từ file homepage.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mode Selector App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(), // Đặt HomePage làm màn hình chính
    );
  }
}
