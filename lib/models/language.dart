class Language {
  final int id;
  final String name, languageCode;

  Language({this.id, this.name, this.languageCode});

  static List<Language> languageList() {
    return <Language>[
      Language(id: 1, name: 'English', languageCode: 'en'),
      Language(id: 2, name: 'español', languageCode: 'es'),
      // Language(id: 3, name: 'Arabic',  languageCode: 'ar'),
      // Language(id: 4, name: 'Hindi',  languageCode: 'hi'),
    ];
  }
}
