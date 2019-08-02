// ignore_for_file: non_constant_identifier_names
import 'package:flutter/cupertino.dart';
import 'package:highlight/common/modes.dart';
import 'package:highlight/common/regexes.dart';
import 'package:highlight/languages/types.dart';
import 'package:meta/meta.dart';

final _OBJECT_ATTR_CONTAINER =
    Mode(begin: R.x(RegExp(r'[{,]\s*')), relevance: 0, contains: [
  Mode(
      begin: R.x(RegExp(IDENT_RE.pattern + r'\s*:')),
      returnBegin: true,
      relevance: 0,
      contains: [Mode(className: 'attr', begin: IDENT_RE, relevance: 0)]),
]);

final _VC_PARAMS = Mode(
  className: 'params',
  variants: [
    Range(begin: IDENT_RE),
    Range(begin: R.x(RegExp(r'\(\s*\)'))),
    Mode(
      begin: R.x(RegExp(r'\(')),
      end: R.x(RegExp(r'\)')),
      excludeBegin: true,
      excludeEnd: true,
      keywords: JavaScript.KEYWORDS,
      contains: JavaScript.PARAMS_CONTAINS,
    ),
  ],
);

final _VC_FUNCTION = Mode(
  className: 'function',
  begin: R.s(r'(\(.*?\\)|' + IDENT_RE.pattern + r')\s*=>'),
  returnBegin: true,
  end: R.s(r'\s*=>'),
  contains: [_VC_PARAMS],
);

final _VC_SKIP = Mode(
  className: '',
  begin: R.x(RegExp('\s')),
  end: R.x(RegExp('\s*')),
  skip: true,
);

final _VC_E4X_JSX = Mode(
    begin: R.x(RegExp(r'<')),
    end: R.x(RegExp(r'(\/[A-Za-z0-9\\._:-]+|[A-Za-z0-9\\._:-]+\/)>')),
    subLanguage: 'xml',
    contains: [
      Mode(begin: R.x(RegExp(r'<[A-Za-z0-9\\._:-]+\s*\/>')), skip: true),
      Mode(
          begin: R.x(RegExp(r'<[A-Za-z0-9\\._:-]+')),
          end: R.x(RegExp(r'(\/[A-Za-z0-9\\._:-]+|[A-Za-z0-9\\._:-]+\/)>')),
          skip: true,
          contains: [
            Mode(
              begin: R.x(RegExp(r'<[A-Za-z0-9\\._:-]+\s*\/>')),
              skip: true,
            ),
            SELF_MODE,
          ])
    ]);

final _VALUE_CONTAINER = Mode(
  begin: R.s('(' + RE_STARTERS_RE.pattern + r'|\b(case|return|throw)\b)\s*'),
  keywords: JustKeywords('return throw case'),
  contains: [
    C_LINE_COMMENT_MODE,
    C_BLOCK_COMMENT_MODE,
    REGEXP_MODE,
    _VC_FUNCTION,
    _VC_SKIP,
    _VC_E4X_JSX,
  ],
  relevance: 0,
);

final _FN_PARAMS = Mode(
    className: 'params',
    begin: R.x(RegExp(r'\(')),
    end: R.x(RegExp(r'\)')),
    excludeBegin: true,
    excludeEnd: true,
    contains: JavaScript.PARAMS_CONTAINS);

final _FUNCTION = Mode(
  className: 'function',
  beginKeywords: JustKeywords('function'),
  end: R.x(RegExp(r'\{')),
  excludeEnd: true,
  contains: [
    TITLE_MODE.copyWith(begin: IDENT_RE),
    _FN_PARAMS,
  ],
  illegal: R.x(RegExp(r'\[|%')),
);

final _RELEVANCE_BOOSTER = Mode(
  begin: R.x(RegExp(r'\$[(.]')),
);

final _ES6_CLASS = Mode(
  className: 'class',
  beginKeywords: JustKeywords('class'),
  end: R.x(RegExp(r'[{;=]')),
  excludeEnd: true,
  illegal: R.x(RegExp(r'[:"\[\]]')),
  contains: [
    Mode(beginKeywords: JustKeywords('extends')),
    UNDERSCORE_TITLE_MODE,
  ],
);

final _CONSTRUCTOR_GET_SET = Mode(
  beginKeywords: JustKeywords('constructor get set'),
  end: R.x(RegExp(r'\{')),
  excludeEnd: true,
);

@immutable
class JavaScriptKeywords extends Keywords {
  const JavaScriptKeywords();

  String get keyword =>
      'in of if for while finally var new function do return void else break catch ' +
      'instanceof with throw case default try this switch continue typeof delete ' +
      'let yield const export super debugger as async await static '
          // ECMAScript 6 modules import
          'import from as';

  String get literal => 'true false null undefined NaN Infinity';

  String get builtIn =>
      'eval isFinite isNaN parseFloat parseInt decodeURI decodeURIComponent '
      'encodeURI encodeURIComponent escape unescape Object Function Boolean Error '
      'EvalError InternalError RangeError ReferenceError StopIteration SyntaxError '
      'TypeError URIError Number Math Date String RegExp Array Float32Array '
      'Float64Array Int16Array Int32Array Int8Array Uint16Array Uint32Array '
      'Uint8Array Uint8ClampedArray ArrayBuffer DataView JSON Intl arguments require '
      'module console window document Symbol Set Map WeakSet WeakMap Proxy Reflect '
      'Promise';
}

class JavaScript {
  static final IDENT_RE = R.s(r'[A-Za-z$_][0-9A-Za-z$_]*');
  static const KEYWORDS = const JavaScriptKeywords();
  static final NUMBER = Mode(
    className: 'number',
    variants: [
      Range(begin: R.s(r'\b(0[bB][01]+)')),
      Range(begin: R.s(r'\b(0[oO][0-7]+)')),
      Range(begin: C_NUMBER_RE),
    ],
    relevance: 0,
  );
  static final SUBST = Mode(
    className: 'subst',
    begin: R.s(r'\$\{'),
    end: R.s(r'\}'),
    keywords: KEYWORDS,
    contains: [
      APOS_STRING_MODE,
      QUOTE_STRING_MODE,
      TEMPLATE_STRING,
      NUMBER,
      REGEXP_MODE
    ],
  );

  static final Iterable<Mode> PARAMS_CONTAINS = SUBST.contains.concat([
    C_BLOCK_COMMENT_MODE,
    C_LINE_COMMENT_MODE,
  ]);

  static final TEMPLATE_STRING = Mode(
    className: 'string',
    begin: R.s('`'),
    end: R.s('`'),
    contains: [BACKSLASH_ESCAPE, SUBST],
  );

  static Language get language {
    return Language(
      aliases: ['js', 'jsx'],
      contains: [
        Mode(
          className: 'meta',
          relevance: 10,
          begin: R.x(RegExp('^\\s*[\'"]use (strict|asm)[\'"]')),
        ),
        APOS_STRING_MODE,
        QUOTE_STRING_MODE,
        TEMPLATE_STRING,
        C_LINE_COMMENT_MODE,
        C_BLOCK_COMMENT_MODE,
        NUMBER,
        _OBJECT_ATTR_CONTAINER,
        _VALUE_CONTAINER,
        _FUNCTION,
        _RELEVANCE_BOOSTER,
        METHOD_GUARD,
        _ES6_CLASS,
        _CONSTRUCTOR_GET_SET,
      ],
      illegal: R.x(RegExp(r'#(?!!)')),
    );
  }
}
