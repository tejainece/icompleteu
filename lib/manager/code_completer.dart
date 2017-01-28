part of manager;

abstract class CodeCompleter {
  Options get options;

  //TODO prepared_triggers

  //TODO _completions_cache

  int completionType(Query query) => 0;

  /// This function is called to check if the code completer can provide code
  /// completion for the current code location.
  ///
  /// This is important to get right. You want to return False if you can't
  /// provide completions because then the identifier completer will kick in,
  /// and that's better than nothing.
  bool shouldUseNow(Query query) {
    /* TODO
    if (!shouldUseNowInner(query)) {
      //TODO invalidate cache
      return false;
    }
    */

    //TODO cache
    return true;
  }

  /* TODO
  bool shouldUseNowInner(Query query);
  */

  bool isQueryLengthAboveMinThreshold(Query query) =>
      query.codeLength >= options.minNumChars;

  /// Computes code completion candidate for given location
  Future<List<CodeCompletionItem>> computeCandidates(Query query) async {
    if (!query.forceSemanticCompletion && !shouldUseNow(query)) return [];

    //TODO search in cache

    List<CodeCompletionItem> result = await computeCandidatesInner(query);

    //TODO update cache

    return result;
  }

  Future<List<CodeCompletionItem>> computeCandidatesInner(Query query);

  List<CodeCompletionItem> filterAndSortResults(
          Query query, List<CodeCompletionItem> candidates) =>
      candidates;

  Future<Null> onFileReadyToParse(Query query) async {}

  Future<Null> onBufferVisit(Query query) async {}

  Future<Null> onBufferUnload(Query query) async {}

  Future<Null> onInsertLeave(Query query) async {}

  Future<Null> onCurrentIdentifierFinished(Query query) async {}

  /// Invokes an event
  Future<dynamic> invokeEvent(String eventName, Query query) async {
    switch (eventName) {
      case 'FileReadyToParse':
        return onFileReadyToParse(query);
        break;
      case 'BufferVisit':
        return onBufferVisit(query);
        break;
      case 'BufferUnload':
        return onBufferUnload(query);
        break;
      case 'InsertLeave':
        return onInsertLeave(query);
        break;
      case 'CurrentIdentifierFinished':
        return onCurrentIdentifierFinished(query);
        break;
      default:
        throw new Exception('Event not supported!');
    }
  }

  /* TODO
  Future<Null> getDiagnosticsForCurrentFile() async {}

  Future<Null> getDetailedDiagnostic();
  */

  /// Returns supported file types
  Set<String> getSupportedFileTypes();

  /* TODO
  String getDebugInfo(Query query);
  */

  /// Shuts down
  Future<Null> shutdown();

  /// Is the server ready
  bool isServerReady() => isServerHealthy();

  /// Is the server healthy
  bool isServerHealthy() => true;
}
