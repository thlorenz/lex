import 'package:highlight/lexers/javascript.dart';

void main() {
  final lexer = JavaScriptLexer();
  for (final token in lexer.getTokensUnprocessed('const hello = 221')) {
    print('$token');
  }
}
