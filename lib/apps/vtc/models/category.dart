import 'package:flutter/material.dart';

class Category {
  final int id;
  final String title;
  final Color color;
  final IconData icon;

  Category({this.id, this.title, this.color, this.icon});
}

List<Category> categorys = [
  Category(
      id: 1,
      title: 'Animation',
      color: Color(0xFF7CB931),
      icon: const IconData(0xe80c, fontFamily: 'CategoryIcon')),
  Category(
      id: 2,
      title: 'Audio',
      color: Color(0xFFF8AA70),
      icon: const IconData(0xe80b, fontFamily: 'CategoryIcon')),
  Category(
      id: 3,
      title: 'Business',
      color: Color(0xFF3C59EA),
      icon: const IconData(0xe819, fontFamily: 'CategoryIcon')),
  Category(
      id: 17,
      title: 'CAD',
      color: Color(0xFFFF9391),
      icon: const IconData(0xe816, fontFamily: 'CategoryIcon')),
  Category(
      id: 4,
      title: 'Certification',
      color: Color(0xFFD94452),
      icon: const IconData(0xe806, fontFamily: 'CategoryIcon')),
  Category(
      id: 5,
      title: 'Databases',
      color: Color(0xFF9B6CEA),
      icon: const IconData(0xe801, fontFamily: 'CategoryIcon')),
  Category(
      id: 16,
      title: 'Game',
      color: Color(0xFFFD4401),
      icon: const IconData(0xe80f, fontFamily: 'CategoryIcon')),
  Category(
      id: 6,
      title: 'Graphics',
      color: Color(0xFFFDCD56),
      icon: const IconData(0xe810, fontFamily: 'CategoryIcon')),
  Category(
      id: 7,
      title: 'Web Design',
      color: Color(0xFFE3B692),
      icon: const IconData(0xe805, fontFamily: 'CategoryIcon')),
  Category(
      id: 8,
      title: 'Multimedia',
      color: Color(0xFFD56FAC),
      icon: const IconData(0xe811, fontFamily: 'CategoryIcon')),
  Category(
      id: 11,
      title: 'Networking',
      color: Color(0xFFFFD600),
      icon: const IconData(0xe80e, fontFamily: 'CategoryIcon')),
  Category(
      id: 9,
      title: 'OS',
      color: Color(0xFF9AC30E),
      icon: const IconData(0xe814, fontFamily: 'CategoryIcon')),
  Category(
      id: 10,
      title: 'Programming',
      color: Color(0xFFE8553E),
      icon: const IconData(0xe818, fontFamily: 'CategoryIcon')),
  Category(
      id: 15,
      title: 'Management',
      color: Color(0xFF636C77),
      icon: const IconData(0xe80d, fontFamily: 'CategoryIcon'))
];
