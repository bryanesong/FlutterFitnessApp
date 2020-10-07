import 'dart:ui';

//class to convert percentages of a screen to pixels

class PSize {
  static double height;
  static double width;

  static double hPix(double percent) {
    if(height != null) {
      return (height * percent / 100).truncate().toDouble();
    } else {
      print("phone size null");
      return 0;
    }

  }

  static double wPix(double percent) {
    if(width != null) {
      return (width * percent / 100).truncate().toDouble();
    } else {
      print("phone size null");
      return 0;
    }
  }
}