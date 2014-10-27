part of spill;

class Brett {
  var nrows = 2;
  var ncols = 2;
  static const hastighet = 5;
  var rowcolors = ["#FF1C0A", "#FFFD0A", "#00A308", "#0008DB", "#EB0093"];
  var paddleh = 10;
  var paddlew = 75;
  var x = 150;
  var y = 150;
  var dx = 2;
  var dy = 4;
  var brickheight = 15;
  var padding = 1;
  var ballr = 10;
  var rightDown = false;
  var leftDown = false;
  var brikkerInitializert = false;
  var ctx;
  var width;
  var height;
  var paddlex;
  var timer;
  var bricks;
  var brickwidth;
  var spill;
  var highscore;
  var brett;
  var start;
  var seier;
  var nullstill;
  var personalia;


  Brett() {
    CanvasElement canvas = querySelector("#canvas");
    ctx = canvas.getContext('2d');

    width = ctx.canvas.height;
    height = ctx.canvas.height;
    paddlex = width / 2;

    brickwidth = (width / ncols) - 1;
    
    highscore = new Highscore();

    leggTilKeyboardListeners();
    gjemHtmlElementer();
  }

  void leggTilKeyboardListeners() {
    document.onKeyDown.listen(onKeyDown);
    document.onKeyUp.listen(onKeyUp);
  }

  void draw() {
    sjekkOmEnBrikkeErTruffet();
    blankBrettet();
    tegnBall();
    flyttOgTegnPadle();
    
    if (!brikkerInitializert) {
      initBrikker();
    }
    
    tegnBrikker();
    koordinerBallOgPadlesBevegelser();
  }

  void koordinerBallOgPadlesBevegelser() {
    if (x + dx + ballr > width || x + dx - ballr < 0) dx = -dx;
    
    if (y + dy - ballr < 0) dy = -dy; else if (y + dy + ballr > height - paddleh) {
      if (x > paddlex && x < paddlex + paddlew) {
        dx = 8 * ((x - (paddlex + paddlew / 2)) / paddlew);
        dy = -dy;
      } else if (y + dy + ballr > height) {
        gameOver();
      }
    }
    
    x += dx;
    y += dy;
  }

  void sjekkOmEnBrikkeErTruffet() {
    var rowheight = brickheight + padding;
    var colwidth = brickwidth + padding;
    var row = (y / rowheight).floor();
    var col = (x / colwidth).floor();
    
    // Sjekke om en brikke er truffet.
    if (y < nrows * rowheight && row >= 0 && col >= 0 && brickHit(row, col)) {
      dy = -dy;
      fjernBrick(row, col);
    }
  }

  void tegnBall() {
    circle(x, y, 10);
  }

  void initBrikker() {
    bricks = new List(nrows);
    for (int i = 0; i < nrows; i++) {
      bricks[i] = new List<int>.filled(ncols, 1);
    }
    
    brikkerInitializert = true;
  }

  void tegnBrikker() {
    for (int i = 0; i < nrows; i++) {
    for (int j = 0; j < ncols; j++) {
      if (skalBrikkenTegnes(i, j)) {
        ctx.fillStyle = rowcolors[i];
        rect((j * (brickwidth + padding)) + padding, (i * (brickheight + padding)) + padding, brickwidth, brickheight);
        }
      }
    }
  }

  bool brickHit(row, col) {
    var brick = bricks[row];
    if (brick[col] == 1) {
      AudioElement treff = querySelector("#treff");
      treff.currentTime = 0;
      treff.load();
      treff.play();

      return true;
    }

    return false;
  }

  bool skalBrikkenTegnes(row, col) {
    var brick = bricks[row];
    return brick[col] == 1;
  }

  bool alleBrikkerFjernet() {
    for (int i = 0; i < nrows; i++) {
      var rad = bricks[i];
      for (int j = 0; j < ncols; j++) {
        if (rad[j] == 1) {
          return false;
        }
      }
    }

    return true;
  }

  void fjernBrick(row, col) {
    var brick = bricks[row];
    brick[col] = 0;
    if (alleBrikkerFjernet()) {
      victory();
    }
  }

  void onKeyDown(evt) {
    if (evt.keyCode == 39) rightDown = true; else if (evt.keyCode == 37) leftDown = true;
  }

  void onKeyUp(evt) {
    if (evt.keyCode == 39) rightDown = false; else if (evt.keyCode == 37) leftDown = false;
  }

  void flyttOgTegnPadle() {
    if (rightDown) {
      paddlex += 5;
    } else if (leftDown) {
      paddlex -= 5;
    }
  
    rect(paddlex, height - paddleh, paddlew, paddleh);
    
  }

  void blankBrettet() {
    ctx.clearRect(0, 0, width, height);
    rect(0, 0, width, height);
    ctx.fillStyle = "black";
    ctx.fill();
  }

  void rect(x, y, w, h) {
    ctx.beginPath();
    ctx.rect(x, y, w, h);
    ctx.closePath();
    ctx.fill();
  }

  void circle(x, y, r) {
    ctx.beginPath();
    ctx.arc(x, y, r, 0, PI * 2, true);
    ctx.fillStyle = "white";
    ctx.closePath();
    ctx.fill();
  }

  void startspill() {
    timer = new Timer.periodic(const Duration(milliseconds: hastighet), (t) => draw());
  }

  void gjemHtmlElementer() {
    start = querySelector("#start");
    seier = querySelector("#highscore");
    nullstill = querySelector("#clear");
    personalia = querySelector("#personalia");
    start.style.display = "none";
    seier.style.display = "none";
    nullstill.style.display = "none";
    personalia.style.display = "none";
  }

  void stoppSpill() {
    timer.cancel();
  }

  void victory() {
    ctx.fillStyle = "white";
    ctx.font = 'italic 40pt Calibri';
    ctx.fillText('Victory', 215, 300);

    MediaElement seier = querySelector("#seier");
    seier.currentTime = 0;
    seier.load();
    seier.play();

    stoppSpill();
    
    highscore.vedseier();

    start.style.display = "block";
  }

  void gameOver() {
    MediaElement gameover = querySelector("#gameover");
    gameover.currentTime = 0;
    gameover.load();
    gameover.play();
    

    ctx.fillStyle = "white";
    ctx.font = 'italic 40pt Calibri';
    ctx.fillText('Game over', 185, 300);
    stoppSpill();
    start.style.display = "block";
  }
}