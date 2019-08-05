import 'package:highlight/common/mode.dart';
import 'package:highlight/common/types.dart';

class Language extends Mode {
  Language({
    this.aliases,
    Keywords keywords,
    R illegal,
    R begin,
    R end,
    Iterable<Mode> contains,
    int relevance,
    this.caseInsensitive = false,
  }) : super(
          keywords: keywords,
          illegal: illegal,
          begin: begin,
          end: end,
          contains: contains,
          relevance: relevance,
        );
  final Iterable<String> aliases;
  final bool caseInsensitive;
}
