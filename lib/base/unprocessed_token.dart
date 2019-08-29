import 'package:equatable/equatable.dart';
import 'package:highlight/base/token.dart';

class UnprocessedToken extends Equatable {
  UnprocessedToken(this.pos, this.token, this.match)
      : super([pos, token, match]);
  final int pos;
  final Token token;
  final String match;

  String toString() {
    return 'UnprocessedToken($pos, $token, \'$match\')';
  }
}
