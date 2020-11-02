import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:flying_hj/game/path_maker.dart';

void main() {
  PathMaker pathMaker;

  setUp(() {
    pathMaker = PathMaker();
  });

  tearDown(() {});

  test("Parabola", () {
    double moveDistnace = 3;
    Offset velocity = Offset(2, 2);
    Offset acceleration = Offset(0, -2);

    List<Offset> parabola = pathMaker.generateParabola(
        Offset(0, 0), velocity, acceleration, moveDistnace,
        unitX: moveDistnace / 5);

    printParabola(parabola);

    velocity = velocity + acceleration * moveDistnace / velocity.dx;

    acceleration = Offset(0, 2.5);
    moveDistnace = 2;

    parabola = pathMaker.generateParabola(
        parabola.last, velocity, acceleration, moveDistnace,
        unitX: moveDistnace / 5);

    printParabola(parabola);

    velocity = velocity + acceleration * moveDistnace / velocity.dx;
    acceleration = Offset(0, -2);
    moveDistnace = 3;

    parabola = pathMaker.generateParabola(
        parabola.last, velocity, acceleration, moveDistnace,
        unitX: moveDistnace / 5);

    printParabola(parabola);
  });

  test("queue test", () {
    final queue = Queue<int>()..addAll([1, 2, 3, 4]);

    queue.take(2);

    print(queue.length);
  });
}

void printParabola(List<Offset> parabola) {
  parabola.forEach((offset) {
    final spaceCount = (offset.dy * 10).round();

    print(List.generate(spaceCount, (index) => ' ')..add("O"));
  });
}
