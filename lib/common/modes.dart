// ignore_for_file: non_constant_identifier_names
import 'package:highlight/common/regexes.dart';
import 'package:highlight/languages/types.dart';

final NEWLINE = R.x(RegExp(r'\n'));

final BACKSLASH_ESCAPE = Mode(
  begin: R.s(r'\\[\s\S]'),
  relevance: 0,
);

final APOS_STRING_MODE = Mode(
  className: 'string',
  begin: R.s('\''),
  end: R.s('\''),
  illegal: NEWLINE,
  contains: [BACKSLASH_ESCAPE],
);

final QUOTE_STRING_MODE = Mode(
  className: 'string',
  begin: R.s('"'),
  end: R.s('"'),
  illegal: NEWLINE,
  contains: [BACKSLASH_ESCAPE],
);

final PHRASAL_WORDS_MODE = Mode(
  begin: R.x(RegExp(
      r"\b(a|an|the|are|I'm|isn't|don't|doesn't|won't|but|just|should|pretty|simply|enough|gonna|going|wtf|so|such|will|you|your|they|like|more)\b")),
);

Mode COMMENT(R begin, R end) {
  return Mode(
    className: 'comment',
    begin: begin,
    end: end,
    contains: [
      PHRASAL_WORDS_MODE,
      Mode(
        className: 'doctag',
        begin: R.s(r'(?:TODO|FIXME|NOTE|BUG|XXX):'),
        relevance: 0,
      ),
    ],
  );
}

final C_LINE_COMMENT_MODE = COMMENT(R.s(r'/'), R.s(r'$'));
final C_BLOCK_COMMENT_MODE = COMMENT(R.s(r'/\*'), R.s(r'\*/'));
final HASH_COMMENT_MODE = COMMENT(R.s(r'#'), R.s(r'$'));

final NUMBER_MODE = Mode(
  className: 'number',
  begin: NUMBER_RE,
  relevance: 0,
);

final C_NUMBER_MODE = Mode(
  className: 'number',
  begin: C_NUMBER_RE,
  relevance: 0,
);
final BINARY_NUMBER_MODE = Mode(
  className: 'number',
  begin: BINARY_NUMBER_RE,
  relevance: 0,
);
final CSS_NUMBER_MODE = Mode(
  className: 'number',
  begin: R.s(NUMBER_RE.pattern +
      '('
          '%|em|ex|ch|rem'
          '|vw|vh|vmin|vmax'
          '|cm|mm|in|pt|pc|px'
          '|deg|grad|rad|turn'
          '|s|ms'
          '|Hz|kHz'
          '|dpi|dpcm|dppx'
          ')?'),
  relevance: 0,
);

final REGEXP_MODE = Mode(
    className: 'regexp',
    begin: R.x(RegExp(r'\//')),
    end: R.x(
      RegExp(r'\/[gimuy]*'),
    ),
    illegal: NEWLINE,
    contains: [
      BACKSLASH_ESCAPE,
      Mode(
          begin: R.x(RegExp(r'\[')),
          end: R.x(RegExp(r'\]')),
          relevance: 0,
          contains: [BACKSLASH_ESCAPE]),
    ]);
final TITLE_MODE = Mode(
  className: 'title',
  begin: IDENT_RE,
  relevance: 0,
);
final UNDERSCORE_TITLE_MODE = Mode(
  className: 'title',
  begin: UNDERSCORE_IDENT_RE,
  relevance: 0,
);
final METHOD_GUARD = Mode(
// excludes method names from keyword processing
  begin: R.s(r'\.\s*' + UNDERSCORE_IDENT_RE.pattern),
  relevance: 0,
);

// Represents 'self' from JavaScript version
final SELF_MODE = SelfMode();
