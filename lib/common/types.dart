import 'package:highlight/languages/mode.dart';
import 'package:meta/meta.dart';

class Tuple<T, U> {
  Tuple(this.first, this.second);
  final T first;
  final U second;
}

abstract class Keywords {
  const Keywords();
  String get keyword;
  String get literal;
  String get builtIn;
}

class JustKeywords extends Keywords {
  JustKeywords(this.keyword);
  final String keyword;
  String get builtIn => null;
  String get literal => null;
}

@immutable
class R {
  const R(
      {String rs, RegExp rx, bool caseInsensitive = false, this.global = false})
      : _rs = rs,
        _rx = rx,
        _caseInsensitive = caseInsensitive;

  factory R.s(String rs, {bool caseInsensitive, bool global}) {
    return R(rs: rs, caseInsensitive: caseInsensitive, global: global);
  }

  factory R.x(RegExp rx, {bool caseInsensitive, bool global}) {
    return R(rx: rx, caseInsensitive: caseInsensitive, global: global);
  }

  final String _rs;
  final RegExp _rx;
  final bool _caseInsensitive;
  final bool global;

  String get pattern => _rs ?? _rx.pattern;

  RegExp value() {
    return _rx ?? RegExp(_rs, caseSensitive: _caseInsensitive);
  }
}

@immutable
class Language extends ModeBase {
  const Language({
    this.aliases,
    Keywords keywords,
    R illegal,
    R begin,
    R end,
    Iterable<ModeBase> contains,
    int relevance,
    this.caseInsensitive = false,
  }) : super(
          keywords: keywords,
          illegal: illegal,
          begin: begin,
          end: end,
          contains: contains,
          relevance: relevance,
        );
  final Iterable<String> aliases;
  final bool caseInsensitive;
}

@immutable
class Mode extends ModeBase {
  const Mode({
    this.subLanguage,
    this.variants,
    this.cachedVariants,
    this.returnBegin,
    this.excludeBegin,
    this.excludeEnd,
    this.skip,
    this.beginKeywords,
    this.lexemes,
    this.variant,
    String className,
    int relevance,
    Keywords keywords,
    R illegal,
    R begin,
    R end,
    Iterable<ModeBase> contains,
  }) : super(
          className: className,
          keywords: keywords,
          illegal: illegal,
          begin: begin,
          end: end,
          contains: contains,
          relevance: relevance,
        );

  final String subLanguage;
  final Iterable<ModeBase> variants;
  final Iterable<ModeBase> cachedVariants;
  final bool returnBegin;
  final bool excludeBegin;
  final bool excludeEnd;
  final bool skip;
  final JustKeywords beginKeywords;
  final R lexemes;

  final ModeBase variant;
  final bool endsWithParent = false;

  ModeBase copyWith({
    Keywords keywords,
    Iterable<ModeBase> variants,
    Iterable<ModeBase> cachedVariants,
    String illegal,
    int relevance,
    bool returnBegin,
    bool excludeBegin,
    bool excludeEnd,
    bool skip,
    R begin,
    R end,
    Iterable<ModeBase> contains,
    ModeBase variant,
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
}

class SelfMode extends ModeBase {}
