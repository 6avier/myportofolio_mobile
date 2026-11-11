import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyPortfolio'),
      ),
      body: const Center(
        child: Text('Halo dari MyPortfolio!'),
      ),
    );
  }
}
