import 'package:flying_hj/game/flyer.dart';

abstract class Field {
  int get width;
  int get height;
  List<Flyer> get hurdles;
  List<List<Flyer>> get walls;
}
