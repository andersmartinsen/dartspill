part of spill;

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
    tidtaking.stopp();
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