import 'package:highlight/common/modes.dart';
import 'package:highlight/common/types.dart';

Iterable<Mode> _expandMode(Mode mode) {
  Iterable<Mode> cachedVariants = mode.cachedVariants;
  if (mode.variants != null && cachedVariants == null) {
    cachedVariants = mode.variants.map((variant) {
      return mode.copyWith(variants: null, variant: variant);
    });
  }
  if (cachedVariants != null) return cachedVariants;
  if (mode.endsWithParent) return [mode.copyWith()];
  return [mode];
}

/* TODO: come back to this disaster, regexes are a lot different in Dart
void _joinRe(List<R> rs, String separator) {
  final backreferenceRe =
      RegExp(r'\[(?:[^\\\]]|\\.)*\]|\(\??|\\([1-9][0-9]*)|\\.');
  int numCaptures = 0;
  String ret = '';
  for (int i = 0; i < rs.length; i++) {
    int offset = numCaptures;
    String re = rs[i].pattern;
    if (i > 0) ret += separator;

    while (re.length > 0) {
      final match = backreferenceRe.firstMatch(re);
      if (match == null) {
        ret += re;
        break;
      }
      ret += re.substring(0, match.start);
      re = re.substring(match.end);
    }
  }
}
 */

class Range {
  Range({this.begin, this.end});
  R begin;
  R end;
}

class Mode extends Range {
  Mode({
    this.className,
    this.keywords,
    this.illegal,
    this.contains,
    this.relevance,
    this.skip,
    this.subLanguage,
    this.variants,
    this.cachedVariants,
    this.returnBegin,
    this.excludeBegin,
    this.excludeEnd,
    this.beginKeywords,
    this.lexemes,
    this.variant,
    this.starts,
    this.endsWithParent = false,
    this.endSameAsBegin = false,
    R begin,
    R end,
  }) : super(begin: begin, end: end);
  final String className;
  Keywords keywords;
  final R illegal;
  List<Mode> contains;
  int relevance;
  final bool skip;

  final String subLanguage;
  final Iterable<Mode> variants;
  final Iterable<Mode> cachedVariants;
  final bool returnBegin;
  final bool excludeBegin;
  final bool excludeEnd;
  final bool endSameAsBegin;
  final JustKeywords beginKeywords;
  R lexemes;

  final Mode variant;
  final Mode starts;
  final bool endsWithParent;

  bool compiled = false;

  Mode copyWith({
    Keywords keywords,
    Iterable<Mode> variants,
    Iterable<Mode> cachedVariants,
    String illegal,
    int relevance,
    bool returnBegin,
    bool excludeBegin,
    bool excludeEnd,
    bool skip,
    R begin,
    R end,
    Iterable<Mode> contains,
    Mode variant,
  }) {
    return Mode(
      keywords: keywords ?? this.keywords,
      variants: variants ?? this.variants,
      cachedVariants: cachedVariants ?? this.cachedVariants,
      illegal: illegal ?? this.illegal,
      relevance: relevance ?? this.relevance,
      returnBegin: returnBegin ?? this.returnBegin,
      excludeBegin: excludeBegin ?? this.excludeBegin,
      excludeEnd: excludeEnd ?? this.excludeEnd,
      skip: skip ?? this.skip,
      begin: begin ?? this.begin,
      end: end ?? this.end,
      contains: contains ?? this.contains,
      variant: variant ?? this.variant,
    );
  }

  //
  // compilation
  //

  Map<String, Tuple<String, int>> compiledKeywords =
      Map<String, Tuple<String, int>>();

  R terminatorEnd;
  R terminators;

  void _flatten(
    String className,
    String str, {
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

  void compile(Mode parent, bool caseInsensitive) {
    if (compiled) return;
    compiled = true;

    keywords = keywords ?? beginKeywords;

    if (keywords != null) {
      if (keywords is JustKeywords) {
        _flatten('keyword', keywords.keyword, caseInsensitive: caseInsensitive);
      } else {
        _flatten('built_in', keywords.builtIn,
            caseInsensitive: caseInsensitive);
        _flatten('keyword', keywords.keyword, caseInsensitive: caseInsensitive);
        _flatten('literal', keywords.literal, caseInsensitive: caseInsensitive);
      }
    }

    lexemes = lexemes ??
        R.x(
          RegExp(r'\w+'),
          caseInsensitive: caseInsensitive,
          global: true,
        );

    if (parent != null) {
      if (beginKeywords != null) {
        begin =
            R.s(r'\b(' + beginKeywords.keyword.split(' ').join('|') + ')\b');
      }
      begin = begin ?? R.x(RegExp(r'\B|\b'));
      if (endSameAsBegin) end = begin;
      if (end == null && !endsWithParent) end = R.x(RegExp(r'\B|\b'));
      if (end != null) terminatorEnd = end;
      if (endsWithParent && terminatorEnd != null) {
        terminatorEnd = R.s(terminatorEnd.pattern +
            (end != null ? '|' : '') +
            terminatorEnd.pattern);
      }
    }

    relevance = relevance ?? 1;

    final Iterable<Iterable<Mode>> expanded =
        (contains ?? []).map((c) => _expandMode(c == SELF_MODE ? this : c));
    contains = [];
    expanded.forEach((exp) => contains.addAll(exp.toList()));

    contains.forEach((c) => c.compile(this, caseInsensitive));

    if (starts != null) {
      starts.compile(parent, caseInsensitive);
    }

    final Iterable<R> allTerminators = contains
        .map((c) => c.beginKeywords != null
            ? R.s(r'\.?(?:' + c.begin.pattern + r')\.?')
            : c.begin)
        .toList()
          ..addAll(<R>[terminatorEnd, illegal]);

    final filteredTerminators = allTerminators.where((c) => c != null);
    // TODO: use joinRe here :365
    terminators = filteredTerminators.isNotEmpty
        ? R.s(filteredTerminators.map((x) => x.pattern).join('|'))
        : null;
  }
}
