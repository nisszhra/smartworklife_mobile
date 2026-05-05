import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/notulen_controller.dart';

class NotulenView extends GetView<NotulenController> {
  const NotulenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NotulenView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'NotulenView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
