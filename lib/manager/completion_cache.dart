part of manager;

class CompletionCacheData {
  final int lineNum;

  final int startCol;

  final int completionType;

  final FilterAndSortBase candidates;

  CompletionCacheData(
      this.lineNum, this.startCol, this.completionType, this.candidates);
}

/// Completions for a particular request
class CompletionCacheStore {
  CompletionCacheData _item;

  void invalidate() {
    _item = null;
  }

  void update(CompletionCacheData item) {
    _item = item;
  }

  FilterAndSortBase getCompletions(
      int lineNum, int startCol, int completionType) {
    if (_item is! CompletionCacheData) return null;
    if (_item.lineNum != lineNum) return null;
    if (_item.startCol != startCol) return null;
    if (_item.completionType != completionType) return null;

    return _item.candidates;
  }
}
