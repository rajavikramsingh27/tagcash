class TutorialItem {
  String id;
  String name;
  String description;
  String imageUrl;
  bool isSelected;

  TutorialItem(
      {this.id, this.name, this.description, this.imageUrl, this.isSelected});

  TutorialItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    imageUrl = json['image_url'];
    isSelected = false;
  }
}
