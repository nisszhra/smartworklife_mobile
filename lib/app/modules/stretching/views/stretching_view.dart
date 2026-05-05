import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/stretching_controller.dart';

class StretchingView extends GetView<StretchingController> {
  const StretchingView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StretchingView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'StretchingView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
