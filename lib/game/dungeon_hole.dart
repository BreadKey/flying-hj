import 'package:flutter/widgets.dart';
import 'package:flying_hj/game/foundation/game_object.dart';

class DungeonHole extends GameObject with ChangeNotifier {
  DungeonHole() : super(4.5, 4.5, 1, 1) {
    canCollide = false;
  }

  static final _images = List.generate(
      3,
      (index) => Image.asset(
            "assets/blackhole/frame${index + 1}.png",
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
            gaplessPlayback: true,
          ));

  int imageIndex = 0;

  @override
  Widget get sprite => _images[imageIndex];

  void activate() {
    canCollide = true;
    notifyListeners();
  }

  void deactivate() {
    canCollide = false;
    notifyListeners();
  }

  void setNextSprite() {
    imageIndex++;
    if (imageIndex == _images.length) {
      imageIndex = 0;
    }
  }
}
