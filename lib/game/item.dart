import 'package:flying_hj/game/flyer.dart';
import 'package:flying_hj/game/foundation/game_object.dart';

abstract class Item extends GameObject {
  double activeTime;
  Item(double width, double height, this.activeTime)
      : super(width, height, width, height);

  void active(Flyer flyer);
  void update(Flyer flyer);
  void end(Flyer flyer);
}
