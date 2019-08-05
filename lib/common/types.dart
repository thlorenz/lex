import 'package:highlight/common/mode.dart';

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

class R {
  R({String rs, RegExp rx, bool caseInsensitive = false, this.global = false})
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
  final bool _caseInsensitive;
  final bool global;
  RegExp _rx;

  String get pattern => value.pattern;

  RegExp get value {
    if (_rx != null) return _rx;
    _rx = RegExp(_rs, caseSensitive: _caseInsensitive);
    return _rx;
  }
}

class SelfMode extends Mode {}
