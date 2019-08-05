// ignore_for_file: non_constant_identifier_names
import 'package:highlight/common/types.dart';

final C_NUMBER_RE = R.s(
    r'(-?)(\b0[xX][a-fA-F0-9]+|(\b\d+(\.\d*)?|\.\d+)([eE][-+]?\d+)?)'); // 0x..., 0..., decimal, float
final IDENT_RE = R.s(r'[a-zA-Z]\w*');
final UNDERSCORE_IDENT_RE = R.s(r'[a-zA-Z_]\w*');
final NUMBER_RE = R.s(r'\b\d+(\.\d+)?');
final BINARY_NUMBER_RE = R.s(r'\b(0b[01]+)'); // 0b...
final RE_STARTERS_RE = R.s(
    r'!|!=|!==|%|%=|&|&&|&=|\*|\*=|\+|\+=|,|-|-=|/=|/|:|;|<<|<<=|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\?|\[|\{|\(|\^|\^=|\||\|=|\|\||~');
