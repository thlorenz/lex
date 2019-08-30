enum Token {
  Text,
  Whitespace,
  Escape,
  Error,
  Other,

  Keyword,
  KeywordConstant,
  KeywordDeclaration,
  KeywordNamespace,
  KeywordPseudo,
  KeywordReserved,
  KeywordType,

  Name,
  NameAttribute,

  NameBuiltin,
  NameBuiltinPseudo,

  NameClass,
  NameConstant,
  NameDecorator,
  NameEntity,
  NameException,

  NameFunction,
  NameFunctionMagic,

  NameProperty,
  NameLabel,
  NameNamespace,
  NameOther,
  NameTag,

  NameVariable,
  NameVariableClass,
  NameVariableGlobal,
  NameVariableInstance,
  NameVariableMagic,

  Literal,
  LiteralDate,

  String,
  StringAffix,
  StringBacktick,
  StringChar,
  StringDelimiter,
  StringDoc,
  StringDouble,
  StringEscape,
  StringHeredoc,
  StringInterpol,
  StringOther,
  StringRegex,
  StringSingle,
  StringSymbol,

  Number,
  NumberBin,
  NumberFloat,
  NumberHex,

  NumberInteger,
  NumberIntegerLong,

  NumberOct,

  Operator,
  OperatorWord,

  Punctuation,

  Comment,
  CommentHashbang,
  CommentMultiline,
  CommentPreproc,
  CommentPreprocFile,
  CommentSingle,
  CommentSpecial,

  Generic,
  GenericDeleted,
  GenericEmph,
  GenericError,
  GenericHeading,
  GenericInserted,
  GenericOutput,
  GenericPrompt,
  GenericStrong,
  GenericSubheading,
  GenericTraceback,

// Special
  IncludeOtherParse,
  ParseByGroups,
}

const POP = '#pop';
const POP2 = '#pop:2';
const PUSH = '#push';

class Parse {
  const Parse(
    this.pattern,
    this.token, [
    this.newStates = null,
  ]);
  factory Parse.include(String s) => Parse(s, Token.IncludeOtherParse);
  factory Parse.bygroups(
    String pattern,
    List<Token> tokens, [
    List<String> nextState,
  ]) =>
      GroupParse(pattern, tokens, nextState);

  factory Parse.empty(List<String> nextState) =>
      Parse('', Token.Text, nextState);

  final String pattern;
  final Token token;
  final List<String> newStates;

  Parse get parent => null;
  List<Token> get groupTokens => null;

  String toString() {
    return '''Parse {
      pattern: $pattern
      token: $token
      newStates: $newStates
    }''';
  }

  List<String> split() {
    List<String> buf = [];
    Parse node = this;
    while (node != null) {
      buf.add(node.toString());
      node = node.parent;
    }
    return buf.reversed;
  }
}

// Yields multiple actions for each group in the match.
class GroupParse extends Parse {
  GroupParse(
    String pattern,
    this.groupTokens, [
    List<String> newStates = null,
  ]) : super(pattern, Token.ParseByGroups);

  final List<Token> groupTokens;
}
