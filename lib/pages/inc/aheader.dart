import 'package:flutter/material.dart';

class Enustkisim extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  const Enustkisim({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.black),
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Image.asset(
          'assets/images/logo2.png',
          height: 32,
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}
