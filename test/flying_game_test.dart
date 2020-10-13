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

    List<Offset> parabola = game.generteParabola(
        Offset(0, 0), velocity, acceleration, moveDistnace,
        interval: moveDistnace * 5 ~/ 1);

    printParabola(parabola);

    velocity = velocity + acceleration * moveDistnace / velocity.dx;

    acceleration = Offset(0, 2.5);
    moveDistnace = 2;

    parabola = game.generteParabola(
        parabola.last, velocity, acceleration, moveDistnace,
        interval: moveDistnace * 5 ~/ 1);

    printParabola(parabola);

    velocity = velocity + acceleration * moveDistnace / velocity.dx;
    acceleration = Offset(0, -2);
    moveDistnace = 3;

    parabola = game.generteParabola(
        parabola.last, velocity, acceleration, moveDistnace,
        interval: moveDistnace * 5 ~/ 1);

    printParabola(parabola);
  });
}

void printParabola(List<Offset> parabola) {
  parabola.forEach((offset) {
    final spaceCount = (offset.dy * 10).round();

    print(List.generate(spaceCount, (index) => ' ')..add("O"));
  });
}
