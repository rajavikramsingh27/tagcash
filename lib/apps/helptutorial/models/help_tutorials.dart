class Tutorial {
  String id;
  String name;
  String description;
  String imageUrl;
  int priceFree;
String priceAdded;
  String priceAmount;
  var totalLessonCredits;

  Tutorial({
    this.id,
    this.name,
    this.description,
    this.imageUrl,
    this.priceFree,
    this.priceAdded,
    this.priceAmount,
    this.totalLessonCredits
  });

  Tutorial.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    imageUrl = json['image_url'];
    priceFree = json['price_free'];
    priceAdded = json['price_added'];
    priceAmount = json['price_amount'];
    totalLessonCredits = json['total_lesson_credits'];
  }
}

class TutorialLesson {
  String lesson;
  String id;
  bool userRead;

  TutorialLesson({
    this.id,
    this.userRead,
    this.lesson
  });

  TutorialLesson.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lesson = json['lesson'];
    userRead = json['user_read'];
  }
}


class TutorialLessonDetails {
  String id;
  String lesson;
  List<TutorialLessonImage> images;
  String movieUrl;

  TutorialLessonDetails({
    this.id,
    this.lesson,
    this.images,
    this.movieUrl
  });

  TutorialLessonDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lesson = json['lesson'];
    images = json['image_url'] != null
                ? List<TutorialLessonImage>.from(json['image_url'].map((x) => TutorialLessonImage.fromJson(x)))
                : new List<TutorialLessonImage>();
    movieUrl = json['movie_url'];
  }
}

class TutorialLessonImage {
  String imageUrl;
  int orderNumber;

  TutorialLessonImage({
    this.imageUrl,
    this.orderNumber
  });

  TutorialLessonImage.fromJson(Map<String, dynamic> json) {
    imageUrl = json['url'].toString();
    orderNumber = json['order_no'];
  }
}