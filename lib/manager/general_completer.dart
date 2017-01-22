part of manager;

class GeneralCodeCompleter extends CodeCompleter {
  final Options options;

  int get minNumChars => options.minNumChars;

  GeneralCodeCompleter(this.options);

  Set<String> getSupportedFileTypes() => new Set();

  Future<Null> shutdown() async {}

  Future<List<CodeCompletionItem>> computeCandidatesInner(Query query) async {
    //TODO

    return [
      new CodeCompletionItem('hello1'),
      new CodeCompletionItem('hello2'),
      new CodeCompletionItem('hello3'),
      new CodeCompletionItem('hello4'),
      ];
  }
}