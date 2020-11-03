import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flying_hj/game/flying_game.dart';
import 'package:provider/provider.dart';

class BackgroundScreen extends StatelessWidget {
  const BackgroundScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<FlyingGame>(context);
    final gameRatio = Provider.of<double>(context);

    return Transform.translate(
      offset: Offset(-game.flyer.width * gameRatio, 0),
      child: Stack(
        children: [
          Transform.translate(
            offset: Offset(game.flyer.x * 0.999 * gameRatio, 0),
            child: RepaintBoundary(
              child: OverflowBox(
                alignment: Alignment.bottomLeft,
                minHeight: MediaQuery.of(context).size.height * 0.618,
                maxWidth: MediaQuery.of(context).size.height * 6.18,
                child: Image.asset(
                  "assets/background/3.png",
                  fit: BoxFit.fitHeight,
                  filterQuality: FilterQuality.none,
                  alignment: Alignment.bottomLeft,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(game.flyer.x * 0.996 * gameRatio, 0),
            child: RepaintBoundary(
              child: OverflowBox(
                  alignment: Alignment.bottomLeft,
                  minHeight: MediaQuery.of(context).size.height * 0.618,
                  maxWidth: MediaQuery.of(context).size.height * 6.18,
                  child: const Background2()),
            ),
          ),
          Transform.translate(
            offset: Offset(game.flyer.x * 0.993 * gameRatio, 0),
            child: RepaintBoundary(
              child: OverflowBox(
                alignment: Alignment.bottomLeft,
                minHeight: MediaQuery.of(context).size.height * 0.618,
                maxWidth: MediaQuery.of(context).size.height * 6.18,
                child: Image.asset(
                  "assets/background/1.png",
                  fit: BoxFit.fitHeight,
                  filterQuality: FilterQuality.none,
                  alignment: Alignment.bottomLeft,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Background2 extends StatefulWidget {
  const Background2() : super();
  @override
  State<StatefulWidget> createState() => _Background2State();
}

class _Background2State extends State<Background2> {
  Timer animator;

  final sprites = [
    Image.asset(
      "assets/background/2-1.png",
      fit: BoxFit.fitHeight,
      filterQuality: FilterQuality.none,
      alignment: Alignment.bottomLeft,
      gaplessPlayback: true,
    ),
    Image.asset(
      "assets/background/2-2.png",
      fit: BoxFit.fitHeight,
      filterQuality: FilterQuality.none,
      alignment: Alignment.bottomLeft,
      gaplessPlayback: true,
    ),
  ];

  int index = 0;

  @override
  void initState() {
    super.initState();
    animator = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        index++;
        if (index == 2) index = 0;
      });
    });
  }

  @override
  void dispose() {
    animator.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return sprites[index];
  }
}
