import 'package:flutter/material.dart';

class BackgroundScreen extends StatelessWidget {
  const BackgroundScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
        alignment: Alignment.bottomLeft,
        minHeight: MediaQuery.of(context).size.height * 0.618,
        maxWidth: MediaQuery.of(context).size.height * 6.18,
        child: Opacity(
          opacity: 0.1618,
          child: Image.asset(
            "assets/background.png",
            fit: BoxFit.fitHeight,
            filterQuality: FilterQuality.none,
            alignment: Alignment.bottomLeft,
          ),
        ));
  }
}