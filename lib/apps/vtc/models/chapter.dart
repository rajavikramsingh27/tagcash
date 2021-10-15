class Chapter {
  final String chapterId, chapter;
  final List<dynamic> lessons;

  Chapter({this.chapterId, this.chapter, this.lessons});

  factory Chapter.fromJson(Map<String, dynamic> item) {
    return Chapter(
      chapterId: item['chapterId'],
      chapter: item['chapter'],
      lessons: item['lessons'],
    );
  }
}
