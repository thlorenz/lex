import 'package:highlight/lexers/typescript.dart';
import 'package:test/test.dart';

import 'regex_lexer_runner.dart';

class TypeScriptLexerRunner extends RegexLexerRunner {
  final lexer = TypeScriptLexer();

  final specs = {
    'export async function canRead(p: string): Promise<boolean> {'
        '  try {'
        '    await access(p, fs.constants.R_OK)'
        '    return true'
        '  } catch (err) {'
        '    return false'
        '  }'
        '}': null
  };
}

void main() {
  group('Lexer: TypeScript', () {
    TypeScriptLexerRunner().run();
  });
}
