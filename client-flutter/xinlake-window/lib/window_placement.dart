// * 2022-03
class WindowPlacement {
  int x, y;
  int width, height;

  bool get isValid {
    return (width > 0) && (height > 0) && (x >= 0) && (y >= 0);
  }

  WindowPlacement({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}
