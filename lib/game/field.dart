import 'package:flutter/material.dart';
import 'package:flying_hj/game/foundation/game_object.dart';

import 'item.dart';

class Field extends ChangeNotifier {
  final List<List<GameObject>> path = [];
  final List<Item> items = <Item>[];

  void addpath(Iterable<Iterable<GameObject>> path) {
    this.path.addAll(path);

    notifyListeners();
  }

  void clear() {
    path.clear();
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
