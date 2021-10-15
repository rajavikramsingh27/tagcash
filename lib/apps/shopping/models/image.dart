import 'dart:convert';

class image {
  int id;
  String image_thumb;
  String images;

  image(
      {this.id,
        this.image_thumb});

  image.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image_thumb = json['image_thumb'];
    images = json['image'];
  }

}
