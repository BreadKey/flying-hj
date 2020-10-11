import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flying_hj/game/field.dart';

class FieldScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FieldScreenState();
}

class _FieldScreenState extends State<FieldScreen> {
  Field field;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    field = Field(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
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
                child: Transform.translate(
                    offset: Offset(field.flyer.x, field.flyer.y),
                    child: Transform.rotate(
                      angle: field.velocity / field.screenHeight * pi / 2,
                      child: SizedBox(
                        width: field.screenHeight *
                            field.flyer.inGameSize /
                            Field.inGameHeight,
                        height: field.screenHeight *
                            field.flyer.inGameSize /
                            Field.inGameHeight,
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
                  field.startUp();
                } else {
                  field.endUp();
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
