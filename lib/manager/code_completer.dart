part of manager;

abstract class CodeCompleter {
  Options get options;

  //TODO prepared_triggers

  final CompletionCacheStore _cache = new CompletionCacheStore();

  int completionType(Query query) => 0;

  /// Should we show code completion popup at the given code point?
  bool shouldUseNow(Query query) {
    if (!shouldUseNowInner(query)) {
      _cache.invalidate();
      return false;
    }

    FilterAndSortBase completions = _cache.getCompletions(
        query.lineNum, query.identifierPosUnicode, completionType(query));

    if (completions is! FilterAndSortBase) return true;
    if (completions.candidates.isEmpty) return false;

    return true;
  }

  bool shouldUseNowInner(Query query) => true;
  //TODO implement triggers
  //TODO    query.identifier is String && query.identifier.isNotEmpty;

  bool isQueryLengthAboveMinThreshold(Query query) =>
      query.identifierLength >= options.minNumChars;

  /// Computes code completion candidate for given location
  Future<List<CodeCompletionItem>> computeCandidates(Query query) async {
    /// Skip if completion not forced and completion is not required
    if (!query.forceSemanticCompletion && !shouldUseNow(query)) return [];

    FilterAndSortBase completions = _cache.getCompletions(
        query.lineNum, query.identifierPosUnicode, completionType(query));

    if (completions is! FilterAndSortBase) {
      completions = createFilterAndSorter(await computeCandidatesInner(query));
      //update cache
      _cache.update(new CompletionCacheData(query.lineNum,
          query.identifierPosUnicode, completionType(query), completions));
    }

    if (query.identifier is! String || query.identifier.isEmpty)
      return completions.candidates;

    return completions.perform(query.identifier);
  }

  Future<List<CodeCompletionItem>> computeCandidatesInner(Query query);

  FilterAndSortBase createFilterAndSorter(
          List<CodeCompletionItem> candidates) =>
      new FilterAndSort.make(candidates);

  Future<List<Map>> onFileReadyToParse(BaseModel query) async => [];

  Future<Null> onBufferVisit(BaseModel query) async {}

  Future<Null> onBufferUnload(BaseModel query) async {}

  Future<Null> onInsertLeave(BaseModel query) async {}

  Future<Null> onCurrentIdentifierFinished(BaseModel query) async {}

  /// Invokes an event
  Future<dynamic> invokeEvent(String eventName, BaseModel query) async {

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

  Future<List<Map>> getDetailedDiagnostic(BaseModel query) async => null;

  /// Returns supported file types
  Set<String> getSupportedFileTypes();

  /// Shuts down
  Future<Null> shutdown();

  /// Is the server ready
  bool isServerReady() => isServerHealthy();

  /// Is the server healthy
  bool isServerHealthy() => true;
}
