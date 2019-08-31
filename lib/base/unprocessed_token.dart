import 'package:equatable/equatable.dart';
import 'package:lexer/base/token.dart';

class UnprocessedToken extends Equatable {
  UnprocessedToken(this.pos, this.token, this.match)
      : super([pos, token, match]);
  final int pos;
  final Token token;
  final String match;

  String toString() {
    return 'UnprocessedToken($pos, $token, \'${_stringifyMatch(match)}\')';
  }

  String _stringifyMatch(String match) {
    if (match == '\n') return '\\n';
    if (match == "'") return "\\'";
    return match;
  }
}
