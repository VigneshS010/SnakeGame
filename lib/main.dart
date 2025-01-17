import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(SnakeGame());
}

class SnakeGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snake Game',
      home: Scaffold(
        // backgroundColor: Color.fromARGB(255, 254, 254, 254),
        body: SnakeGamePage(),
      ),
    );
  }
}

class SnakeGamePage extends StatefulWidget {
  @override
  _SnakeGamePageState createState() => _SnakeGamePageState();
}

class _SnakeGamePageState extends State<SnakeGamePage> {
  static const int numSquares = 15;
  static const int snakeInitialLength = 3;

  late List<List<bool>> grid;
  late List<Point<int>> snake;
  late Timer timer;
  late bool isPlaying;
  late String direction;
  late Point<int> food;
  int speed = 300; // default speed in milliseconds

  @override
  void initState() {
    super.initState();
    initGame();
  }

  void initGame() {
    grid = List.generate(numSquares, (_) => List.filled(numSquares, false));
    snake = [];
    for (int i = 0; i < snakeInitialLength; i++) {
      snake.add(Point((numSquares / 2).floor(), (numSquares / 2).floor() + i));
    }
    direction = 'up';
    food = generateFood();
    isPlaying = true; // Initialize isPlaying to true
    timer = Timer.periodic(Duration(milliseconds: speed), (Timer timer) {
      if (isPlaying) {
        setState(() {
          moveSnake();
        });
      }
    });
  }

  Point<int> generateFood() {
    Random random = Random();
    Point<int> foodPoint;
    do {
      int x = random.nextInt(numSquares);
      int y = random.nextInt(numSquares);
      foodPoint = Point(x, y);
    } while (snake.contains(foodPoint));
    return foodPoint;
  }

  void paint(Canvas canvas, Size size) {
  Paint paint = Paint()
   ..color = Colors.green
   ..style = PaintingStyle.fill;

  for (int i = 0; i < snake.length; i++) {
    Point<int> point = snake[i];
    double x = point.x * size.width / numSquares;
    double y = point.y * size.height / numSquares;
    double width = size.width / numSquares;
    double height = size.height / numSquares;

    if (direction == 'up') {
      canvas.drawRect(Rect.fromLTWH(x, y, width, height), paint);
    } else if (direction == 'down') {
      canvas.drawRect(Rect.fromLTWH(x, y + height, width, -height), paint);
    } else if (direction == 'left') {
      canvas.drawRect(Rect.fromLTWH(x, y, -width, height), paint);
    } else if (direction == 'right') {
      canvas.drawRect(Rect.fromLTWH(x + width, y, -width, height), paint);
    }
  }
}

void moveSnake() {
    Point<int> newHead = snake[0];
    switch (direction) {
      case 'up':
        newHead = Point(newHead.x, newHead.y - 1);
        if (newHead.y < 0) newHead = Point(newHead.x, numSquares - 1);
        break;
      case 'down':
        newHead = Point(newHead.x, newHead.y + 1);
        if (newHead.y >= numSquares) newHead = Point(newHead.x, 0);
        break;
      case 'left':
        newHead = Point(newHead.x - 1, newHead.y);
        if (newHead.x < 0) newHead = Point(numSquares - 1, newHead.y);
        break;
      case 'right':
        newHead = Point(newHead.x + 1, newHead.y);
        if (newHead.x >= numSquares) newHead = Point(0, newHead.y);
        break;
    }
    // Check if the snake bites itself
    if (snake.sublist(1).contains(newHead)) {
      gameOver();
      return;
    }
    snake.insert(0, newHead);
    if (newHead == food) {
      food = generateFood();
    } else {
      snake.removeLast();
    }
    updateContainer(); // Call the updateContainer() function here
  }

  void updateContainer() {
    // Get the current direction of the snake
    String direction = getSnakeDirection();

    // Update the container's appearance based on the direction
    switch (direction) {
      case 'up':
        // Fill the container from top to bottom
        break;
      case 'down':
        // Fill the container from bottom to top
        break;
      case 'left':
        // Fill the container from left to right
        break;
      case 'right':
        // Fill the container from right to left
        break;
    }
  }
  String getSnakeDirection() {
    return direction;
  }

  void gameOver() {
    timer.cancel();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('Score: ${snake.length - snakeInitialLength}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                initGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void changeDirection(String newDirection) {
    if ((newDirection == 'up' && direction != 'down') ||
        (newDirection == 'down' && direction != 'up') ||
        (newDirection == 'left' && direction != 'right') ||
        (newDirection == 'right' && direction != 'left')) {
      setState(() {
        direction = newDirection;
      });
    }
  }

  void toggleSpeed() {
    setState(() {
      if (speed == 300) {
        speed = 100; // Change speed to 150 milliseconds
      } else {
        speed = 300; // Change speed back to 200 milliseconds
      }
      timer.cancel(); // Cancel current timer
      timer = Timer.periodic(Duration(milliseconds: speed), (Timer timer) {
        if (isPlaying) {
          setState(() {
            moveSnake();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Text(
            'Score: ${snake.length - snakeInitialLength}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0) {
                    changeDirection('down');
                  } else if (details.delta.dy < 0) {
                    changeDirection('up');
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx > 0) {
                    changeDirection('right');
                  } else if (details.delta.dx < 0) {
                    changeDirection('left');
                  }
                },
                child: CustomPaint(
                   painter: SnakePainter(snake: snake, direction: direction),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: numSquares,
                    ),
                    itemCount: numSquares * numSquares,
                    itemBuilder: (BuildContext context, int index) {
                      int x = index % numSquares;
                      int y = index ~/ numSquares;
                      bool isSnake = snake.contains(Point(x, y));
                      bool isFood = food == Point(x, y);
                      return Container(
                        margin: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: isSnake
                              ? Colors.green
                              : isFood
                                  ? Colors.red
                                  : grid[x][y]
                                      ? Colors.white
                                      : Colors.white,
                          //border: Border.all(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => changeDirection('up'),
                child: const Icon(Icons.keyboard_arrow_up),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => changeDirection('left'),
                child: const Icon(Icons.keyboard_arrow_left),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => changeDirection('down'),
                child: const Icon(Icons.keyboard_arrow_down),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => changeDirection('right'),
                child: const Icon(Icons.keyboard_arrow_right),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: toggleSpeed,
            child: Text('Toggle Speed: ${speed == 100 ? 'Fast' : 'Slow'}'),
          ),
        ],
      ),
    );
  }
}


class SnakePainter extends CustomPainter {
  final List<Point<int>> snake;
  final String direction;

  SnakePainter({required this.snake, required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    // Implement the painting logic here
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
