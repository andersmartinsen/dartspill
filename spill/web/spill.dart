import 'dart:html';
import 'dart:math';
import 'dart:async';

class Highscore {
  Storage localStorage = window.localStorage;
  DivElement seier, personalia;
  InputElement nullstillHighscore;
  Tidtaking tidtaking;

  Highscore() {
    tidtaking = new Tidtaking();
    tidtaking.start();
    personalia = querySelector("#personalia");
    seier = querySelector("#highscore");
  }

  void vedseier() {
    if (spillerenSkalPaaHighscoreLista()) {
      personalia.style.display = "block";

      InputElement navn = querySelector('#navn');
      InputElement lagre = querySelector('#lagre');

      lagre.onClick.listen((Event e) {
        personalia.style.display = "none";
        haandtereHighscoreLista(navn.value);
      });

      navn.onKeyUp.listen((evt) {
        if (evt.keyCode == KeyCode.ENTER) {
          personalia.style.display = "none";
          haandtereHighscoreLista(navn.value);
        }
      });

    } else {
      visHighscoreLista();
    }
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

    InputElement nullstillHighscore = querySelector("#clear");
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

class Brett {
  var ctx;
  var width;
  var height;
  var x = 150;
  var y = 150;
  var dx = 2;
  var dy = 4;
  var paddlex;
  var paddleh;
  var paddlew;
  var timer;
  var bricks;
  var nrows = 1;
  var ncols = 1;
  var brickwidth;
  var brickheight;
  var padding;
  var ballr = 10;
  var rowcolors = ["#FF1C0A", "#FFFD0A", "#00A308", "#0008DB", "#EB0093"];
  var rightDown = false;
  var leftDown = false;
  var spill;
  static const hastighet = 10;
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
    paddleh = 10;
    paddlew = 75;

    brickwidth = (width / ncols) - 1;
    brickheight = 15;
    padding = 1;

    highscore = new Highscore();

    leggTilKeyboardListeners();
    gjemHtmlElementer();
  }

  void leggTilKeyboardListeners() {
    document.onKeyDown.listen(onKeyDown);
    document.onKeyUp.listen(onKeyUp);
  }

  void draw() {
    clear();
    tegnBall();
    flyttPadle();
    initBrikker();

    var rowheight = brickheight + padding;
    var colwidth = brickwidth + padding;
    var row = (y / rowheight).floor();
    var col = (x / colwidth).floor();

    // Sjekke om en brikke er truffet.
    if (y < nrows * rowheight && row >= 0 && col >= 0 && brickHit(row, col)) {
      dy = -dy;
      fjernBrick(row, col);
    }

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

  void tegnBall() {
    circle(x, y, 10);
  }

  void initBrikker() {
    bricks = new List(nrows);
    for (int i = 0; i < nrows; i++) {
      bricks[i] = new List<int>.filled(ncols, 1);
    }

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

  void flyttPadle() {
    if (rightDown) {
      paddlex += 5;
    } else if (leftDown) {
      paddlex -= 5;
    }

    rect(paddlex, height - paddleh, paddlew, paddleh);
  }

  void clear() {
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
    if (seier != null) {
      seier.play();
    }

    stoppSpill();
    highscore.vedseier();

    start.style.display = "block";
  }

  void gameOver() {
    MediaElement gameover = querySelector("#gameover");
    gameover.currentTime = 0;
    gameover.play();

    ctx.fillStyle = "white";
    ctx.font = 'italic 40pt Calibri';
    ctx.fillText('Game over', 185, 300);
    stoppSpill();
    start.style.display = "block";
  }
}

class Spill {

  void initBrett() {
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
  new Spill()..initBrett();
}
