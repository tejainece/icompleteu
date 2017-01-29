library icu_server.api.models;

import 'dart:collection';
import 'package:icu_server/api/models/models.dart';
import 'package:bit_set/bit_set.dart';

List<String> splitWords(String text, BitSet bitset) {
  final currentRunes = <int>[];
  final words = <String>[];
  for (int rune in text.runes) {
    if (rune <= 127) bitset[rune] = true;
    if (rune >= 97 && rune <= 122) {
      currentRunes.add(rune);
      continue;
    }

    if (currentRunes.isNotEmpty) {
      words.add(new String.fromCharCodes(currentRunes));
    }

    currentRunes.clear();
    if (rune >= 65 && rune <= 90) {
      currentRunes.add(rune - 65 + 97);
    } else {
      currentRunes.add(rune);
    }
  }

  if (currentRunes.isNotEmpty) {
    words.add(new String.fromCharCodes(currentRunes));
  }

  return words;
}

class FilterAndSortState {
  final List<String> words;

  final BitSet bitset;

  FilterAndSortState(this.words, this.bitset);

  factory FilterAndSortState.make(CodeCompletionItem item) {
    BitSet bitSet = new BitSet(128, false);
    final List<String> words = splitWords(item.insertionText, bitSet);
    return new FilterAndSortState(words, bitSet);
  }
}

class FilterAndSort implements FilterAndSortBase {
  final UnmodifiableListView<CodeCompletionItem> candidates;

  final UnmodifiableListView<FilterAndSortState> states;

  FilterAndSort(this.candidates, this.states);

  factory FilterAndSort.make(List<CodeCompletionItem> candidates) {
    final states =
        new UnmodifiableListView(candidates.map((CodeCompletionItem item) {
      return new FilterAndSortState.make(item);
    }));
    return new FilterAndSort(new UnmodifiableListView(candidates), states);
  }

  List<CodeCompletionItem> perform(String query) {
    BitSet bitSet = new BitSet(128, false);
    final List<String> words = splitWords(query, bitSet);

    final List<_Scored> filtered = [];

    for (int itemIdx = 0; itemIdx < candidates.length; itemIdx++) {
      final FilterAndSortState item = states[itemIdx];
      //TODO if (!bitSet.and(item.bitset).contains(true)) continue;

      bool itemFailed = false;
      int score = 0;
      int matchedChars = 0;

      for (int wordIdx = 0; wordIdx < words.length; wordIdx++) {
        final String word = words[wordIdx];
        bool wordFailed = true;
        for (int itemWordIdx = 0;
            itemWordIdx < item.words.length;
            itemWordIdx++) {
          final String itemWord = item.words[itemWordIdx];
          final int matchIdx = itemWord.indexOf(word);
          if (matchIdx == -1) {
            continue;
          }

          wordFailed = false;

          //if 'itemWord' starts with 'word', give it more priority
          if (matchIdx == 0) {
            score++;
            if(word.length == itemWord.length) score++;
          }
          //Score ordered word matches higher
          if (wordIdx == itemWordIdx) score += 2;
          matchedChars += word.length;
        }
        if (wordFailed) {
          itemFailed = true;
          break;
        }
      }

      if (!itemFailed) {
        filtered.add(new _Scored(candidates[itemIdx], score));
      }
    }

    filtered.sort(_Scored.compare);

    return filtered.map((_Scored s) => s.contained).toList();
  }
}

class _Scored {
  final int score;

  final CodeCompletionItem contained;

  _Scored(this.contained, this.score);

  static int compare(_Scored a, _Scored b) {
    int diff = b.score.compareTo(a.score);
    if (diff != 0) return diff;
    return b.contained.insertionText.length
        .compareTo(a.contained.insertionText.length);
  }
}

abstract class FilterAndSortBase {
  UnmodifiableListView<CodeCompletionItem> get candidates;

  List<CodeCompletionItem> perform(String query);
}
