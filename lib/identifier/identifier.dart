library icompleteu.identifier;

final RegExp _defaultIdentifierRegex = new RegExp("[^\W\d]\w*");

final RegExp _cssIdentifierRegexp = new RegExp("-?[_a-zA-Z]+[\w-]+");

final RegExp _clojureIdentifierRegexp =
    new RegExp("[-\*\+!_\?:\.a-zA-Z][-\*\+!_\?:\.\w]*/?[-\*\+!_\?:\.\w]*");

final Map<String, RegExp> _identifierRegexMap = {
  'css': _cssIdentifierRegexp,
  'html': new RegExp("[a-zA-Z][^\s/>='\"}{\.]*"),
  'r': new RegExp("(?!(?:\.\d|\d|_))[\.\w]+"),
  'clojure': _clojureIdentifierRegexp,
  'haskell': new RegExp("[_a-zA-Z][\w']+"),
  'tex': new RegExp("[_a-zA-Z:-]+"),
  'perl6': new RegExp("[_a-zA-Z](?:\w|[-'](?=[_a-zA-Z]))*"),
  'scss': _cssIdentifierRegexp,
  'sass': _cssIdentifierRegexp,
  'less': _cssIdentifierRegexp,
  'elisp': _clojureIdentifierRegexp,
  'lisp': _clojureIdentifierRegexp,
};

RegExp getIdentifierRegexForFileType(String fileType) =>
    _identifierRegexMap[fileType] ?? _defaultIdentifierRegex;

bool isIdentifier(String text, String fileType) {
  if (text is! String) return false;

  final RegExp regex = getIdentifierRegexForFileType(fileType);
  final Match match = regex.firstMatch(text);
  return match is Match && match.end == text.length;
}

int startOfLongestIdentifierEndingAtIndex(
    String lineVal, int columnVal, String fileType) {
  if (lineVal is! String || columnVal < 1 || columnVal > lineVal.length) {
    return columnVal;
  }

  for (int i = 0; i < columnVal; i++) {
    if (isIdentifier(lineVal.substring(i, columnVal), fileType)) return i;
  }

  return columnVal;
}
