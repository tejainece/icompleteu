library icompleteu.identifier;

final RegExp defaultIdentifierRegex = new RegExp(r"^[^\W\d]\w*$");

final RegExp _cssIdentifierRegexp = new RegExp(r"^-?[_a-zA-Z]+[\w-]+$");

final RegExp _clojureIdentifierRegexp =
    new RegExp(r"^[-\*\+!_\?:\.a-zA-Z][-\*\+!_\?:\.\w]*/?[-\*\+!_\?:\.\w]*$");

final Map<String, RegExp> _identifierRegexMap = {
  'css': _cssIdentifierRegexp,
  'html': new RegExp(r"""^[a-zA-Z][^\s/>='"}{\.]*$"""),
  'r': new RegExp(r"^(?!(?:\.\d|\d|_))[\.\w]+$"),
  'clojure': _clojureIdentifierRegexp,
  'haskell': new RegExp(r"^[_a-zA-Z][\w']+$"),
  'tex': new RegExp(r"^[_a-zA-Z:-]+$"),
  'perl6': new RegExp(r"^[_a-zA-Z](?:\w|[-'](?=[_a-zA-Z]))*$"),
  'scss': _cssIdentifierRegexp,
  'sass': _cssIdentifierRegexp,
  'less': _cssIdentifierRegexp,
  'elisp': _clojureIdentifierRegexp,
  'lisp': _clojureIdentifierRegexp,
};

RegExp getIdentifierRegexForFileType(String fileType) =>
    _identifierRegexMap[fileType] ?? defaultIdentifierRegex;

bool isIdentifier(String text, String fileType) {
  if (text is! String) return false;

  final RegExp regex = getIdentifierRegexForFileType(fileType);
  final Match match = regex.firstMatch(text);
  return match is Match;
}

int startOfLongestIdentifierEndingAtIndex(
    String lineVal, int columnVal, String fileType) {
  if (lineVal is! String || columnVal < 1 || (columnVal-1) > lineVal.length) {
    return 1;
  }

  for (int i = 0; i < columnVal; i++) {
    if (isIdentifier(lineVal.substring(i, columnVal-1), fileType)) return (i+1);
  }

  return columnVal;
}
