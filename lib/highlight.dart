library highlight;

class Highlighter {
  getLanguage(String name) {
    name = (name ?? '').toLowerCase();
    // return languages[name] || languages[aliases[name]];
  }

  highlight(String name, String code) {
    final language = getLanguage(name);
    if (language == null) throw Exception('Unknown language $name!');
    language.compile(language.caseSensitive);
  }
}
