import 'package:flutter/material.dart';
import 'package:flying_hj/game/game_object.dart';

import 'item.dart';

class Field extends ChangeNotifier {
  final List<List<GameObject>> walls = [];
  final List<Item> items = <Item>[];

  void addWalls(Iterable<Iterable<GameObject>> walls) {
    this.walls.addAll(walls);

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
