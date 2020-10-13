import 'package:flying_hj/game/game_object.dart';

class Field {
  final int width;
  final List<List<GameObject>> walls;

  Field(this.width, this.walls);
}
