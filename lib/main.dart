import 'package:flutter/material.dart';

void main() {
  runApp(const StrideApp());
}

class StrideApp extends StatelessWidget {
  const StrideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stride',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Stride App - Em desenvolvimento'),
        ),
      ),
    );
  }
}
