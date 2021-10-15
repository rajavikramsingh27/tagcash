import '../models/thread.dart';
import '../services/base_response.dart';
import '../utils/core/parsing.dart';

class History extends BaseResponse {
  List<dynamic> threads;
  bool hasNextPage;
  bool hasPrevPage;
  int limit;
  int nextPage;
  int page;
  int pagingCounter;
  int prevPage;
  int totalDocs;
  int totalPages;

  History.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.hasNextPage = Parsing.boolFrom(json['hasNextPage']);
    this.hasPrevPage = Parsing.boolFrom(json['hasPrevPage']);
    this.limit = Parsing.intFrom(json['limit']);
    this.nextPage = Parsing.intFrom(json['nextPage']);
    this.page = Parsing.intFrom(json['page']);
    this.pagingCounter = Parsing.intFrom(json['pagingCounter']);
    this.prevPage = Parsing.intFrom(json['prevPage']);
    this.totalDocs = Parsing.intFrom(json['totalDocs']);
    this.totalPages = Parsing.intFrom(json['totalPages']);
    this.threads = Parsing.arrayFrom(json['docs']).isNotEmpty ? json['docs'].map((e) => Thread.fromJson(Parsing.mapFrom(e))).toList() : [];
  }

  Map<String, dynamic> toMap() => {
        'threads': this.threads.map((e) => e.toMap()).toList(),
        'hasNextPage': this.hasNextPage,
        'hasPrevPage': this.hasPrevPage,
        'nextPage': this.nextPage,
        'prevPage': this.prevPage,
        'limit': this.limit,
        'page': this.page,
        'pagingCounter': this.pagingCounter,
        'totalDocs': this.totalDocs,
        'totalPages': this.totalPages
      };
}
