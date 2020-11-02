import 'package:flutter/material.dart';
import 'package:flying_hj/game/foundation/game_object.dart';
import 'package:flying_hj/game/wall.dart';

import 'item.dart';

class Field extends ChangeNotifier {
  final List<Wall> walls = [];
  final List<Item> items = <Item>[];

  void addWalls(Iterable<Wall> walls) {
    this.walls.addAll(walls);
    notifyListeners();
  }

  void addPath(Iterable<Iterable<GameObject>> path) {
    this.walls.addAll(path.expand((walls) => walls));

    notifyListeners();
  }

  void clear() {
    walls.clear();
    items.clear();
    notifyListeners();
  }

  void addItem(Item item) {
    items.add(item);
    notifyListeners();
  }

  void removeItem(Item item) {
    items.remove(item);
    notifyListeners();
  }
}
