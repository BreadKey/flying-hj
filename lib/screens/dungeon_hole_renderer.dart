import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flying_hj/game/dungeon_hole.dart';

class DungeonHoleRenderer extends StatefulWidget {
  final DungeonHole dungeonHole;
  final double gameRatio;
  final double width;
  final double height;

  DungeonHoleRenderer(
      {Key key, @required this.dungeonHole, @required this.gameRatio})
      : this.width = dungeonHole.spriteWidth * gameRatio,
        this.height = dungeonHole.spriteHeight * gameRatio,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _DugeonHallRenderState();
}

class _DugeonHallRenderState extends State<DungeonHoleRenderer>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> rotateAnimation;
  Timer spriteChangeTimer;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    rotateAnimation = Tween(begin: 1.0, end: 0.0).animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    spriteChangeTimer.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DungeonHoleRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.dungeonHole.canCollide) {
      animationController.repeat();
      spriteChangeTimer =
          Timer.periodic(const Duration(milliseconds: 200), (_) {
        widget.dungeonHole.setNextSprite();
        setState(() {});
      });
    } else {
      animationController.stop();
      spriteChangeTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.dungeonHole.canCollide
        ? Transform.translate(
            offset: center,
            child: RepaintBoundary(
              child: RotationTransition(
                turns: rotateAnimation,
                child: SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child: widget.dungeonHole.sprite,
                ),
              ),
            ))
        : const SizedBox.shrink();
  }

  Offset get center =>
      Offset((widget.dungeonHole.x - widget.dungeonHole.spriteWidth / 2),
          -(widget.dungeonHole.y - widget.dungeonHole.spriteHeight / 2)) *
      widget.gameRatio;
}
