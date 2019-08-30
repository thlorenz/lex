import 'package:highlight/base/token.dart';
import 'package:highlight/base/types.dart';
import 'package:highlight/base/unprocessed_token.dart';

export 'package:highlight/base/token.dart';
export 'package:highlight/base/types.dart';
export 'package:highlight/base/unprocessed_token.dart';

// TODO: this should use the given lexer in order do the following:
//  Callback that processes the match with a different lexer.
//
//  The keyword arguments are forwarded to the lexer, except `state` which
//  is handled separately.
//
//  `state` specifies the state that the new lexer will start in, and can
//  be an enumerable such as ('root', 'inline', 'string') or a simple
//  string which is assumed to be on top of the root state.
//
// For now we just treat this as text.
Token using(RegexLexer lexer) {
  return Token.Text;
}

abstract class Lexer {
  Lexer({
    this.stripnl = true,
    this.stripall = false,
    this.ensurenl = true,
    this.tabsize = 0,
    this.encoding = 'guess',
  });
  final bool stripnl;
  final bool stripall;
  final bool ensurenl;
  final int tabsize;
  final String encoding;
  // TODO: left out filter related things
  // final List<String> filters;

  String get name => null;
  List<String> get aliases => [];
  List<String> get filenames => [];
  List<String> get aliasFilenames => [];
  List<String> get mimetypes => [];
  int get priority => 0;

  // Has to return a float between ``0`` and ``1`` that indicates if a lexer wants to highlight this text. Used by ``guess_lexer``.
  // If this method returns ``0`` it won't highlight it in any case, if
  // it returns ``1`` highlighting with this lexer is guaranteed.
  //
  // The `LexerMeta` metaclass automatically wraps this function so
  // that it works like a static method (no ``self`` or ``cls``
  // parameter) and the return value is automatically converted to
  // `float`. If the return value is an object that is boolean `False`
  // it's the same as if the return values was ``0.0``.
  double analyseText(String text) {
    throw new UnimplementedError(
        'Either inheritor or regex lexer needs to implement this');
  }

  // Return an iterable of (index, tokentype, value) pairs where "index"
  // is the starting position of the token within the input text.
  //
  // In subclasses, implement this method as a generator to
  // maximize effectiveness.

  Iterable<UnprocessedToken> getTokensUnprocessed(String text);

  // Return an iterable of (tokentype, value) pairs generated from
  // `text`. If `unfiltered` is set to `True`, the filtering mechanism
  // is bypassed even if filters are defined.
  //
  // Also preprocess the text, i.e. expand tabs and strip it if
  // wanted and applies registered filters.
  List<Parse> getTokens(String text, {bool unfiltered = false}) {
    // text now *is* a unicode string (TODO: conversion once needed)
    text = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    if (stripall) text = text.trim();
    // TODO: how to trim \n in dart; else if (stripnl) text = text.trim('\n');

    if (tabsize > 0) text.replaceAll('\t', ''.padLeft(tabsize));
    if (ensurenl && !text.endsWith('\n')) text += '\n';

    return null;
  }
}

typedef RegExpMatch RexMatch(String text, int pos);

// http://pygments.org/docs/lexerdevelopment
//
// The lexer base class used by almost all of Pygments’ lexers is the
// RegexLexer.
// This class allows you to define lexing rules in terms of regular
// expressions for different states.
//
// States are groups of regular expressions that are matched against the
// input string at the current position.
// If one of these expressions matches, a corresponding action is performed
// (such as yielding a token with a specific type, or changing state),
// the current position is set to where the last match ended and
// the matching process continues with the first regex of the current state.
//
// Lexer states are kept on a stack: each time a new state is entered,
// the new state is pushed onto the stack.
// The most basic lexers (like the DiffLexer) just need one state.
//
// Each state is defined as a list of tuples in the form
// (regex, action, new_state) where the last item is optional.
// In the most basic form, action is a token type (like Name.Builtin).
// That means: When regex matches, emit a token with the match text and type
// tokentype and push new_state on the state stack.

// If the new state is '#pop', the topmost state is popped from the stack
// instead. To pop more than one state, use '#pop:2' and so on.
// '#push' is a synonym for pushing the current state on the stack.
abstract class RegexLexer extends Lexer {
  RegExpFlags get flags;
  Map<String, List<Parse>> get parses;

  // Split ``text`` into (token type, text) pairs.
  //
  // ``stack`` is the initial stack (default: ``['root']``)
  //
  // The get_tokens_unprocessed() method must return an iterator or iterable
  // containing tuples in the form (index, token, value).
  // Stream<Tuple2<index, token, value>>
  Iterable<UnprocessedToken> getTokensUnprocessed(
    String text, [
    List<String> stack,
  ]) sync* {
    int pos = 0;
    Map<String, Iterable<Parse>> parsedefs = _expand(parses);
    final List<String> statestack = stack ?? List.from(['root']);
    List<Parse> statetokens = parsedefs[statestack.last];
    while (true && pos < text.length) {
      bool matched = false;
      for (final parse in statetokens) {
        final pattern = parse.pattern;
        final token = parse.token;
        final newStates = parse.newStates;

        final regex = RegExp(
          pattern,
          dotAll: flags.dotAll,
          unicode: flags.unicode,
          multiLine: flags.multiline,
          caseSensitive: flags.caseSensitive,
        );
        final m = regex.matchAsPrefix(text, pos);

        if (m != null) {
          if (token != null && m.group(0).isNotEmpty) {
            if (token == Token.ParseByGroups) {
              yield* this._bygroup(m, parse.groupTokens);
            } else {
              yield UnprocessedToken(pos, token, m.group(0));
            }
          }
          pos = m.end;
          if (newStates != null) {
            for (final state in newStates) {
              if (state == POP)
                this._pop(statestack, 1);
              else if (state == POP2)
                this._pop(statestack, 2);
              else if (state == PUSH)
                statestack.add(statestack.last);
              else
                statestack.add(state);
            }
            statetokens = statestack.isEmpty
                ? parsedefs['root']
                : parsedefs[statestack.last];
          }
          matched = true;
          break;
        }
      }

      if (!matched) {
        // We are here only if all state tokens have been considered
        // and there was not a match on any of them.
        try {
          if (text[pos] == '\n') {
            _popTo(statestack, 'root');
            statetokens = parsedefs['root'];
            yield UnprocessedToken(pos, Token.Text, '\n');
            pos++;
            continue;
          }
          yield UnprocessedToken(pos, Token.Error, text[pos]);
          pos++;
        } on Exception catch (err) {
          print(err);
          break;
        }
      }
    }
  }

  // Callback that yields multiple actions for each group in the match.
  Iterable<UnprocessedToken> _bygroup(Match m, Iterable<Token> tokens) sync* {
    // TODO: not yet dealing with nested lexer
    int groupIdx = 1;
    int pos = m.start;
    for (final token in tokens) {
      final s = m.group(groupIdx);
      yield UnprocessedToken(pos, token, s);
      pos += s.length;
      groupIdx++;
    }
  }

  void _pop(List<String> statestack, int times) {
    while (statestack.isNotEmpty && times > 0) {
      statestack.removeLast();
      times--;
    }
  }

  void _popTo(List<String> statestack, String target) {
    while (statestack.last != target && statestack.isNotEmpty) {
      statestack.removeLast();
    }
  }

  Map<String, List<Parse>> _expand(Map<String, List<Parse>> parsesMap) {
    final expanded = Map<String, List<Parse>>();
    Iterable<Parse> expandList(List<Parse> parses) sync* {
      for (final p in parses) {
        if (p.token == Token.IncludeOtherParse) {
          yield* expandList(parsesMap[p.pattern]);
        } else {
          yield p;
        }
      }
    }

    for (final entry in parses.entries) {
      expanded[entry.key] = expandList(entry.value).toList();
    }
    return expanded;
  }
}
