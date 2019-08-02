library highlight;

import 'package:highlight/common/modes.dart';
import 'package:highlight/languages/types.dart';

void flatten(
  String className,
  String str,
  Map<String, Tuple<String, int>> compiledKeywords, {
  bool caseInsensitive,
}) {
  String keywords = str;
  if (caseInsensitive) keywords = keywords.toLowerCase();
  keywords.split(' ').forEach((String keyword) {
    final List<String> pair = keyword.split('|');
    compiledKeywords[pair[0]] =
        Tuple(className, pair[1] != null ? int.tryParse(pair[1]) ?? 1 : 1);
  });
}

Iterable<Mode> expandedMode(Mode mode) {
  Iterable<Mode> cachedVariants = mode.cachedVariants;
  if (mode.variants != null && cachedVariants == null) {
    cachedVariants = mode.variants.map((variant) {
      // TODO: why in the world do we now need another single variant?!?
      return mode.copyWith(variants: null, variant: variant);
    });
  }
  if (cachedVariants != null) return cachedVariants;
  if (mode.endsWithParent) return [mode.copyWith()];
  return [mode];
}

class CompiledMode {
  factory CompiledMode.fromMode(Language language, Mode mode, dynamic parent) {
    final keywords = mode.keywords ?? mode.beginKeywords;
    final compiledKeywords = Map<String, Tuple<String, int>>();
    if (mode.keywords != null) {
      if (mode.keywords is JustKeywords) {
        flatten('keyword', mode.keywords.keyword, compiledKeywords);
      } else {
        flatten('built_in', mode.keywords.builtIn, compiledKeywords);
        flatten('keyword', mode.keywords.keyword, compiledKeywords);
        flatten('literal', mode.keywords.literal, compiledKeywords);
      }
    }
    final R lexemseRe = mode.lexemes ??
        R.x(
          RegExp(r'\w+'),
          caseInsensitive: language.caseInsensitive,
          global: true,
        );

    if (parent != null) {
      /* TODO: haven't seen a parent so far
        if (mode.beginKeywords) {
          mode.begin = '\\b(' + mode.beginKeywords.split(' ').join('|') + ')\\b';
        }
        if (!mode.begin)
          mode.begin = /\B|\b/;
        mode.beginRe = langRe(mode.begin);
        if (mode.endSameAsBegin)
          mode.end = mode.begin;
        if (!mode.end && !mode.endsWithParent)
          mode.end = /\B|\b/;
        if (mode.end)
          mode.endRe = langRe(mode.end);
        mode.terminator_end = reStr(mode.end) || '';
        if (mode.endsWithParent && parent.terminator_end)
          mode.terminator_end += (mode.end ? '|' : '') + parent.terminator_end;
     */
    }
    final illegalRe = mode.illegal;
    final relevance = mode.relevance ?? 1;
    final contains =
        (mode.contains ?? []).map((c) => c == SELF_MODE ? mode : c); // :350
    return null;
  }

  final Map<String, Tuple<String, int>> keywords;
  final RegExp lexemseRe;
}

class Highlighter {
  getLanguage(String name) {
    name = (name ?? '').toLowerCase();
    // return languages[name] || languages[aliases[name]];
  }

  highlight(String name, String code) {
    final language = getLanguage(name);
    if (language == null) throw Exception('Unknown language $name!');
  }
}
