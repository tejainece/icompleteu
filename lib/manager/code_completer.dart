part of manager;

abstract class CodeCompleter {
  Options get options;

  int get minNumChars;

  //TODO prepared_triggers

  //TODO _completions_cache

  int completionType(Query query) => 0;

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

  Future<List<CodeCompletionItem>> computeCandidates(Query query) async {
    if (!query.forceSemantic && !shouldUseNow(query)) return [];

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

  Future<dynamic> invokeEvent(String eventName, Query query) async {
    switch(eventName) {
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

  Set<String> getSupportedFileTypes();

  /* TODO
  String getDebugInfo(Query query);
  */

  Future<Null> shutdown();

  bool isServerReady() => isServerHealthy();

  bool isServerHealthy() => true;
}