part of manager;

class CodeCompletionItem {
  /// Completed code
  final String insertionText;

  /// Display text
  final String extraMenuInfo;

  /// Description
  final String detailedInfo;

  final String menuText;

  final String kind;

  final Map<String, dynamic> extraData;

  const CodeCompletionItem(this.insertionText,
      {this.extraMenuInfo,
      this.detailedInfo,
      this.menuText,
      this.kind,
      this.extraData});
}

class CodeCompletionResponse {
  final List<CodeCompletionItem> items;

  final int startColumn;

  final List<String> errors;

  const CodeCompletionResponse(this.items, this.startColumn, {this.errors});
}
