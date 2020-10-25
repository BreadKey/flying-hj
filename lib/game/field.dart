import 'package:flutter/material.dart';
import 'package:flying_hj/game/foundation/game_object.dart';
import 'package:flying_hj/game/skyscraper.dart';

import 'item.dart';

class Field extends ChangeNotifier {
  final List<List<GameObject>> walls = [];
  final List<Item> items = <Item>[];
  final List<Skyscraper> skyscrapers = <Skyscraper>[];

  void addWalls(Iterable<Iterable<GameObject>> walls) {
    this.walls.addAll(walls);

    notifyListeners();
  }

  void clear() {
    walls.clear();
    items.clear();
    skyscrapers.forEach((skyscraper) {
      skyscraper.dispose();
    });
    skyscrapers.clear();
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

  void removeSkyscraper(Skyscraper skyscraper) {
    skyscraper.dispose();
    skyscrapers.remove(skyscraper);
    notifyListeners();
  }
}
