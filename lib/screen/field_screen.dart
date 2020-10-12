import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flying_hj/game/field.dart';

class FieldScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FieldScreenState();
}

class _FieldScreenState extends State<FieldScreen> {
  Field field;
  double flyerSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    field = Field(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    flyerSize = field.inGameRatio * field.flyer.inGameSize;
    field.startGame();

    field.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox.expand(
          child: Stack(
        children: [
          Container(
            color: Colors.lightBlue,
            child: Align(
                alignment: Alignment.topLeft,
                /// Alignmnet is top left. so center flyer
                child: Transform.translate(
                    offset: Offset(field.flyer.x - flyerSize / 2,
                        field.flyer.y - flyerSize / 2),
                    child: Transform.rotate(
                      angle: field.flyer.angle,
                      child: SizedBox(
                        width: flyerSize,
                        height: flyerSize,
                        child: field.flyer.image,
                      ),
                    ))),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: MaterialButton(
              color: Colors.pink,
              onHighlightChanged: (value) {
                if (value) {
                  field.startFly();
                } else {
                  field.endFly();
                }
              },
              onPressed: () {
                if (field.isGameOver) {
                  field.startGame();
                }
              },
            ),
          )
        ],
      ));
}
