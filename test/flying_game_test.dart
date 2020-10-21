import 'package:flutter_test/flutter_test.dart';
import 'package:flying_hj/game/flying_game.dart';

void main() {
  FlyingGame game;

  setUp(() {
    game = FlyingGame();
  });

  tearDown(() {
    game.dispose();
  });

  test("Parabola", () {
    double moveDistnace = 3;
    Offset velocity = Offset(2, 2);
    Offset acceleration = Offset(0, -2);

    List<Offset> parabola = game.generateParabola(
        Offset(0, 0), velocity, acceleration, moveDistnace,
        unitX: moveDistnace / 5);

    printParabola(parabola);

    velocity = velocity + acceleration * moveDistnace / velocity.dx;

    acceleration = Offset(0, 2.5);
    moveDistnace = 2;

    parabola = game.generateParabola(
        parabola.last, velocity, acceleration, moveDistnace,
        unitX: moveDistnace / 5);

    printParabola(parabola);

    velocity = velocity + acceleration * moveDistnace / velocity.dx;
    acceleration = Offset(0, -2);
    moveDistnace = 3;

    parabola = game.generateParabola(
        parabola.last, velocity, acceleration, moveDistnace,
        unitX: moveDistnace / 5);

    printParabola(parabola);
  });
}

void printParabola(List<Offset> parabola) {
  parabola.forEach((offset) {
    final spaceCount = (offset.dy * 10).round();

    print(List.generate(spaceCount, (index) => ' ')..add("O"));
  });
}
