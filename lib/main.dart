import 'package:highlight/lexers/javascript.dart';

void main() {
  final lexer = JavaScriptLexer();
  for (final token in lexer.getTokensUnprocessed('const s = 221')) {
    print('[${token.first}]: ${token.second} \'${token.third}\'');
  }
}
