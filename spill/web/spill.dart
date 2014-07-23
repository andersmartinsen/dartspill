import 'dart:html';
import 'dart:math';
import 'dart:async';


void main() {
  const hastighet = 10;
  var x = 150;
  var y = 150;
  var dx = 2;
  var dy = 4;
  var ctx;
  var WIDTH;
  var HEIGHT;
  var paddlex;
  var paddleh;
  var paddlew;
  var timer;
  var bricks;
  var NROWS;
  var NCOLS;
  var BRICKWIDTH;
  var BRICKHEIGHT;
  var PADDING;
  var ballr = 10;
  var rightDown = false;
  var leftDown = false;
  var rowcolors = ["#FF1C0A", "#FFFD0A", "#00A308", "#0008DB", "#EB0093"];

  CanvasElement canvas = querySelector("#canvas");
  ctx = canvas.getContext('2d');

  WIDTH = ctx.canvas.height;
  HEIGHT = ctx.canvas.height;

  ctx.rect(0, 0, WIDTH, HEIGHT);
  ctx.fillStyle = "black";
  ctx.fill();

  paddlex = WIDTH / 2;
  paddleh = 10;
  paddlew = 75;

  NROWS = 5;
  NCOLS = 5;
  BRICKWIDTH = (WIDTH / NCOLS) - 1;
  BRICKHEIGHT = 15;
  PADDING = 1;

  bricks = new List(NROWS);
  for (int i = 0; i < NROWS; i++) {
    bricks[i] = new List<int>.filled(NCOLS, 1);
  }

  void onKeyDown(evt) {
    if (evt.keyCode == 39) rightDown = true; else if (evt.keyCode == 37) leftDown = true;
  }

  void onKeyUp(evt) {
    if (evt.keyCode == 39) rightDown = false; else if (evt.keyCode == 37) leftDown = false;
  }

  document.onKeyDown.listen(onKeyDown);
  document.onKeyUp.listen(onKeyUp);

  void circle(x, y, r) {
    ctx.beginPath();
    ctx.arc(x, y, r, 0, PI * 2, true);
    ctx.fillStyle = "white";
    ctx.closePath();
    ctx.fill();
  }

  void rect(x, y, w, h) {
    ctx.beginPath();
    ctx.rect(x, y, w, h);
    ctx.closePath();
    ctx.fill();
  }

  void clear() {
    ctx.clearRect(0, 0, WIDTH, HEIGHT);
    rect(0, 0, WIDTH, HEIGHT);
    ctx.fillStyle = "black";
    ctx.fill();
  }

  bool brickHit(row, col) {
    var brick = bricks[row];
    if (brick[col] == 1) {
      MediaElement treff = querySelector("#treff");
      if (treff != null) {
        treff.play();
      }

      return true;
    }

    return false;
  }

  bool skalBrikkenTegnes(row, col) {
    var brick = bricks[row];
    return brick[col] == 1;
  }

  bool alleBrikkerFjernet() {
    for (int i = 0; i < NROWS; i++) {
      var rad = bricks[i];
      for (int j = 0; j < NCOLS; j++) {
        if (rad[j] == 1) {
          return false;
        }
      }
    }
    
    return true;
  }

  void victory() {
    ctx.fillStyle = "white";
    ctx.font = 'italic 40pt Calibri';
    ctx.fillText('Victory', 215, 300);

    MediaElement seier = querySelector("#seier");
    if (seier != null) {
      seier.play();
    }

    timer.cancel();
  }

  void fjernBrick(row, col) {
    var brick = bricks[row];
    brick[col] = 0;
    if (alleBrikkerFjernet()) {
      victory();
    }
  }

  void gameOver() {
    MediaElement gameover = querySelector("#gameover");
    if (gameover != null) {
      gameover.play();
    }

    ctx.fillStyle = "white";
    ctx.font = 'italic 40pt Calibri';
    ctx.fillText('Game over', 185, 300);
    timer.cancel();
  }

  void tegnBall() {
    circle(x, y, 10);
  }

  void initBrikker() {
    for (int i = 0; i < NROWS; i++) {
      for (int j = 0; j < NCOLS; j++) {
        if (skalBrikkenTegnes(i, j)) {
          ctx.fillStyle = rowcolors[i];
          rect((j * (BRICKWIDTH + PADDING)) + PADDING, (i * (BRICKHEIGHT + PADDING)) + PADDING, BRICKWIDTH, BRICKHEIGHT);
        }
      }
    }
  }

  void flyttPadle() {
    if (rightDown) {
      paddlex += 5;
    } else if (leftDown) {
      paddlex -= 5;
    }

    rect(paddlex, HEIGHT - paddleh, paddlew, paddleh);
  }

  void draw() {
    clear();
    tegnBall();
    flyttPadle();
    initBrikker();

    var rowheight = BRICKHEIGHT + PADDING;
    var colwidth = BRICKWIDTH + PADDING;
    var row = (y / rowheight).floor();
    var col = (x / colwidth).floor();

    // Sjekke om en brikke er truffet.
    if (y < NROWS * rowheight && row >= 0 && col >= 0 && brickHit(row, col)) {
      dy = -dy;
      fjernBrick(row, col);
    }

    if (x + dx + ballr > WIDTH || x + dx - ballr < 0) dx = -dx;

    if (y + dy - ballr < 0) dy = -dy; else if (y + dy + ballr > HEIGHT - paddleh) {
      if (x > paddlex && x < paddlex + paddlew) {
        dx = 8 * ((x - (paddlex + paddlew / 2)) / paddlew);
        dy = -dy;
      } else if (y + dy + ballr > HEIGHT) gameOver();
    }

    x += dx;
    y += dy;
  }

  timer = new Timer.periodic(const Duration(milliseconds: hastighet), (t) => draw());
}
