import 'dart:ui';

//class to convert percentages of a screen to pixels

class PSize {
  static double _height;


  static double _width;

  static double hPix(double percent) {
    if(_height != null) {
      return (_height * percent / 100).truncate().toDouble();
    } else {
      print("phone size null");
      return 0;
    }

  }

  static double wPix(double percent) {
    if(_width != null) {
      return (_width * percent / 100).truncate().toDouble();
    } else {
      print("phone size null");
      return 0;
    }
  }

  static set width(double value) {
    _width = value;
  }

  static set height(double value) {
    _height = value;
  }

}