import 'dart:html';
import 'dart:math';
import 'dart:async';

class Board {


}

class Ball {

}

class Highscore {
  Storage localStorage = window.localStorage;
  DivElement seier;
  InputElement nullstillHighscore;
  Tidtaking tidtaking;

  Highscore() {
    tidtaking = new Tidtaking();
    init();
  }

  void init() {
    seier = querySelector("#highscore");
    seier.style.display = "none";

    nullstillHighscore = querySelector("#clear");
    nullstillHighscore.style.display = "none";
  }

  void nullstillHtmlLista() {
    LIElement forste = querySelector('#forste');
    forste.text = "";
    LIElement andre = querySelector('#andre');
    andre.text = "";
    LIElement tredje = querySelector('#tredje');
    tredje.text = "";
  }

  void visHighscoreLista() {
    if (localStorage['forsteTid'] != null) {
      LIElement forste = querySelector('#forste');
      forste.text = localStorage['forsteNavn'] + " - " + localStorage['forsteTid'] + "s";
    }

    if (localStorage['andreTid'] != null) {
      LIElement andre = querySelector('#andre');
      andre.text = localStorage['andreNavn'] + " - " + localStorage['andreTid'] + "s";
    }

    if (localStorage['tredjeTid'] != null) {
      LIElement tredje = querySelector('#tredje');
      tredje.text = localStorage['tredjeNavn'] + " - " + localStorage['tredjeTid'] + "s";
    }

    seier.style.display = "block";

    InputElement clear = querySelector("clear");
    nullstillHighscore.onClick.listen((evt) {
      localStorage.clear();
      nullstillHtmlLista();
    });

    nullstillHighscore.style.display = "block";
  }

  bool spillerenSkalPaaHighscoreLista() {
    int varighet = tidtaking.bruktISekunder();
    if (localStorage['forsteTid'] == null) {
      return true;
    } else if (localStorage['forsteTid'] != null && varighet < int.parse(localStorage['forsteTid'])) {
      return true;
    } else if (localStorage['andreTid'] == null) {
      return true;
    } else if (localStorage['andreTid'] != null && varighet < int.parse(localStorage['andreTid'])) {
      return true;
    } else if (localStorage['tredjeTid'] == null) {
      return true;
    } else if (localStorage['tredjeTid'] != null && varighet < int.parse(localStorage['tredjeTid'])) {
      return true;
    }

    return false;
  }

  void haandtereHighscoreLista(String navn) {
    int varighet = tidtaking.bruktISekunder();

    String forsteTid = localStorage['forsteTid'];
    String andreTid = localStorage['andreTid'];
    String tredjeTid = localStorage['tredjeTid'];

    if (forsteTid == null) {
      localStorage['forsteTid'] = varighet.toString();
      localStorage['forsteNavn'] = navn;
    } else if (forsteTid != null && varighet < int.parse(forsteTid)) {
      localStorage['forsteTid'] = varighet.toString();
      localStorage['forsteNavn'] = navn;
    } else if (andreTid == null) {
      localStorage['andreTid'] = varighet.toString();
      localStorage['andreNavn'] = navn;
    } else if (andreTid != null && varighet < int.parse(andreTid)) {
      localStorage['andreTid'] = varighet.toString();
      localStorage['andreNavn'] = navn;
    } else if (tredjeTid == null) {
      localStorage['tredjeTid'] = varighet.toString();
      localStorage['tredjeNavn'] = navn;
    } else if (tredjeTid != null && varighet < int.parse(tredjeTid)) {
      localStorage['tredjeTid'] = varighet.toString();
      localStorage['tredjeNavn'] = navn;
    }

    visHighscoreLista();
  }
}

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
  MediaElement treff;

  Highscore highscore = new Highscore();

  var startevent;

  InputElement start = querySelector("#start");

  DivElement personalia = querySelector("#personalia");
  personalia.style.display = "none";

  CanvasElement canvas = querySelector("#canvas");
  ctx = canvas.getContext('2d');

  WIDTH = ctx.canvas.height;
  HEIGHT = ctx.canvas.height;

  // Svart bakgrunn på spillet
  ctx.rect(0, 0, WIDTH, HEIGHT);
  ctx.fillStyle = "black";
  ctx.fill();

  paddlex = WIDTH / 2;
  paddleh = 10;
  paddlew = 75;

  NROWS = 1;
  NCOLS = 1;
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

    if (highscore.spillerenSkalPaaHighscoreLista()) {
      personalia.style.display = "block";

      InputElement navn = querySelector('#navn');
      InputElement lagre = querySelector('#lagre');

      lagre.onClick.listen((Event e) {
        personalia.style.display = "none";
        highscore.haandtereHighscoreLista(navn.value);
      });

      navn.onKeyUp.listen((evt) {
        if (evt.keyCode == KeyCode.ENTER) {
          personalia.style.display = "none";
          highscore.haandtereHighscoreLista(navn.value);
        }
      });

    } else {
      highscore.visHighscoreLista();
    }

    start.style.display = "block";
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
    start.style.display = "block";
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

  void startspill() {
    main();
    timer = new Timer.periodic(const Duration(milliseconds: hastighet), (t) => draw());
  }

  start.onClick.listen((evt) {
    startspill();
    start.style.display = "none";
  });


  //timer = new Timer.periodic(const Duration(milliseconds: hastighet), (t) => draw());
}
