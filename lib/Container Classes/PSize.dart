class PSize {
  static int width;
  static int height;

  static double hPix(double percent) {
    return height * percent / 100;
  }

  static double wPix(double percent) {
    return width * percent / 100;
  }
}