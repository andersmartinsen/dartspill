import 'dart:html';
import 'dart:math';
import 'dart:async';

void main() {

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
  var rightDown = false;
  var leftDown = false;
  var touchStartX;
  var bricks;
  int NROWS;
  int NCOLS;
  var BRICKWIDTH;
  var BRICKHEIGHT;
  var PADDING;
  var ballr = 10;
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


  //set rightDown or leftDown if the right or left keys are down
  void onKeyDown(evt) {
    if (evt.keyCode == 39) rightDown = true; else if (evt.keyCode == 37) leftDown = true;
  }

  //and unset them when the right or left key is released
  void onKeyUp(evt) {
    if (evt.keyCode == 39) rightDown = false; else if (evt.keyCode == 37) leftDown = false;
  }

  document.onKeyDown.listen(onKeyDown);
  document.onKeyUp.listen(onKeyUp);

  /*document.onTouchStart.listen((TouchEvent event) {
    event.preventDefault();

    if (event.touches.length > 0) {
      touchStartX = event.touches[0].page.x;
    }
  });

  document.onTouchMove.listen((TouchEvent event) {
    event.preventDefault();

    if (touchStartX != null && event.touches.length > 0) {
      int newTouchX = event.touches[0].page.x;

      if (newTouchX > touchStartX) {
        spinFigure(target, (newTouchX - touchStartX) ~/ 20 + 1);
        touchStartX = null;
      } else if (newTouchX < touchStartX) {
        spinFigure(target, (newTouchX - touchStartX) ~/ 20 - 1);
        touchStartX = null;
      }
    }
  });
  */

  void circle(x, y, r) {
    ctx.beginPath();
    ctx.arc(x, y, r, 0, PI * 2, true);
    //ctx.strokeStyle(ballcolor);
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

  void fjernBrick(row, col) {
    var brick = bricks[row];
    brick[col] = 0;
  }
  
  void gameOver() {
    timer.cancel();
  }

  void draw() {
    clear();
    circle(x, y, 10);

    if (rightDown) paddlex += 5; else if (leftDown) paddlex -= 5;
    rect(paddlex, HEIGHT - paddleh, paddlew, paddleh);

    // draw bricks
    for (int i = 0; i < NROWS; i++) {
      for (int j = 0; j < NCOLS; j++) {
        if (skalBrikkenTegnes(i, j)) {
          ctx.fillStyle = rowcolors[i];
          rect((j * (BRICKWIDTH + PADDING)) + PADDING, (i * (BRICKHEIGHT + PADDING)) + PADDING, BRICKWIDTH, BRICKHEIGHT);
        }
      }
    }

    var rowheight = BRICKHEIGHT + PADDING;
    var colwidth = BRICKWIDTH + PADDING;
    var row = (y / rowheight).floor();
    var col = (x / colwidth).floor();
    //reverse the ball and mark the brick as broken
    if (y < NROWS * rowheight && row >= 0 && col >= 0 && brickHit(row, col)) {
      dy = -dy;
      bricks[row][col] = 0;
    }

    if (x + dx + ballr > WIDTH || x + dx - ballr < 0) dx = -dx;

    if (y + dy - ballr < 0) dy = -dy; else if (y + dy + ballr > HEIGHT - paddleh) {
      if (x > paddlex && x < paddlex + paddlew) {
        //move the ball differently based on where it hit the paddle
        dx = 8 * ((x - (paddlex + paddlew / 2)) / paddlew);
        dy = -dy;
      } else if (y + dy + ballr > HEIGHT) gameOver();
    }

    x += dx;
    y += dy;
  }

  timer = new Timer.periodic(const Duration(milliseconds: 10), (t) => draw());
}
