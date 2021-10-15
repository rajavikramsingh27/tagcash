import 'package:flutter/material.dart';
import 'package:tagcash/utils/string_format.dart';

class Course {
  final String name,
      author,
      releaseDate,
      movieCount,
      totalTime,
      sku,
      categoryId;
  final Color color;

  Course(
      {this.name,
      this.author,
      this.releaseDate,
      this.movieCount,
      this.totalTime,
      this.sku,
      this.categoryId,
      this.color});

  factory Course.fromJson(Map<String, dynamic> item) {
    return Course(
      name: item['name'],
      author: item['author'],
      releaseDate: item['releaseDate'],
      movieCount: item['movieCount'],
      totalTime: item['totalTime'],
      sku: item['sku'],
      categoryId: item['categoryId'],
      color: StringFormat.stringToColor(item['name']),
    );
  }
}
