import 'package:flutter/material.dart';
import 'package:dannexpress/appBar.dart';
import 'package:dannexpress/connectivity_wrapper.dart';

class Apropos extends StatelessWidget {
  const Apropos({super.key});

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      child: Scaffold(
        appBar: const MyAppBar(
          title: 'À propos',
          showBack: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text("apropos de MES Afrique"),
            ],
          ),
        ),
      ),
    );
  }
}