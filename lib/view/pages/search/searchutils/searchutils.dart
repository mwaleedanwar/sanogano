import '../../../../utils.dart';

String getStringUpperBound(String str) {
  var len = str.length;
  if (len == 1) return getNextCharacter(str);
  var s = str.substring(0, len - 1);
  s = s + getNextCharacter(str[len - 1]);
  return s;
}

String getNextCharacter(String char) {
  var index = alphabets.indexOf(char);
  if (char == "z") return "zz";
  if (char == "Z") return "ZZ";
  return alphabets[index + 1];
}



var alphabets = [
  "A",
  "B",
  "C",
  "D",
  "E",
  "F",
  "G",
  "H",
  "I",
  "J",
  "K",
  "L",
  "M",
  "N",
  "O",
  "P",
  "Q",
  "R",
  "S",
  "T",
  "U",
  "V",
  "W",
  "X",
  "Y",
  "Z",
  "a",
  "b",
  "c",
  "d",
  "e",
  "f",
  "g",
  "h",
  "i",
  "j",
  "k",
  "l",
  "m",
  "n",
  "o",
  "p",
  "q",
  "r",
  "s",
  "t",
  "u",
  "v",
  "w",
  "x",
  "y",
  "z"
];
