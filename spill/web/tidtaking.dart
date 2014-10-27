part of spill;

class Tidtaking {
  Stopwatch stopwatch;

  void start() {
    stopwatch = new Stopwatch();
    stopwatch.start();
  }

  void stopp() {
    if (stopwatch != null) {
      stopwatch.stop();
    }
  }

  int bruktISekunder() {
    if (stopwatch != null) {
      return stopwatch.elapsed.inSeconds;
    }
    return 0;
  }
}