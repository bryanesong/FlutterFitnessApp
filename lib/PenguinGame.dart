import 'dart:ui';
import 'package:flame/game.dart';

class PenguinGame extends Game{
  Size screenSize;
  @override
  void render(Canvas canvas){
    Rect bgRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint bgPaint = Paint();
    bgPaint.color = Color(0xFF576574);
    canvas.drawRect(bgRect,bgPaint);

  }

  @override
  void update(double t){

  }
  @override
  void resize(Size size){
    super.resize(size);
    screenSize = size;
  }
}