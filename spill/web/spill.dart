library spill;

import 'dart:html';
import 'dart:math';
import 'dart:async';

part 'highscore.dart';
part 'tidtaking.dart';
part 'brett.dart';

class Spill {
  
  void init() {
    CanvasElement canvas = querySelector("#canvas");
    var ctx = canvas.getContext('2d');
    var width = ctx.canvas.height;
    var height = ctx.canvas.height;

    ctx.rect(0, 0, width, height);
    ctx.fillStyle = "black";
    ctx.fill();

    var highscore = querySelector("#highscore");
    highscore.style.display = "none";

    var nullstillHighscore = querySelector("#clear");
    nullstillHighscore.style.display = "none";

    var personalia = querySelector("#personalia");
    personalia.style.display = "none";

    var start = querySelector("#start");
    start.onClick.listen((evt) {
      var brett = new Brett();
      brett.startspill();
    });
  }
}

void main() {
  new Spill()..init();
}
