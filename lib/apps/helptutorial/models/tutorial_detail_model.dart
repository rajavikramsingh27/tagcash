class TutorialDetailModel {
  String id;
  String name;
  String description;
  OwnerDetails ownerDetails;
  String roleId;
  String priceAdded;
  String priceWalletId;
  String priceAmount;
  String totalLessonCredits;
  int totalLessonCount;
  int priceFree;
  String imageName;
  String imageUrl;
  List<String> chapterPriority;
  bool isFavourite;
  int tutorialPurchasedStatus;
  List<Chapters> chapters;
  int lessonSizeInSeconds;
  String lessonTotalLength;

  TutorialDetailModel(
      {this.id,
      this.name,
      this.description,
      this.ownerDetails,
      this.roleId,
      this.priceAdded,
      this.priceWalletId,
      this.priceAmount,
      this.totalLessonCredits,
      this.totalLessonCount,
      this.priceFree,
      this.imageName,
      this.imageUrl,
      this.chapterPriority,
      this.isFavourite,
      this.tutorialPurchasedStatus,
      this.chapters,
      this.lessonSizeInSeconds,
      this.lessonTotalLength});

  TutorialDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    ownerDetails = json['ownerDetails'] != null
        ? new OwnerDetails.fromJson(json['ownerDetails'])
        : null;
    roleId = json['role_id'];
    priceAdded = json['price_added'];
    priceWalletId = json['price_wallet_id'];
    priceAmount = json['price_amount'];
    totalLessonCredits = json['total_lesson_credits'];
    totalLessonCount = json['total_lesson_count'];
    priceFree = json['price_free'];
    imageName = json['image_name'];
    imageUrl = json['image_url'];
    chapterPriority = json['chapter_priority'].cast<String>();
    isFavourite = json['is_favourite'];
    tutorialPurchasedStatus = json['tutorial_purchased_status'];
    if (json['chapters'] != null) {
      chapters = new List<Chapters>();
      json['chapters'].forEach((v) {
        chapters.add(new Chapters.fromJson(v));
      });
    }
    lessonSizeInSeconds = json['lesson_size_in_seconds'];
    lessonTotalLength = json['lesson_total_length'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    if (this.ownerDetails != null) {
      data['ownerDetails'] = this.ownerDetails.toJson();
    }
    data['role_id'] = this.roleId;
    data['price_added'] = this.priceAdded;
    data['price_wallet_id'] = this.priceWalletId;
    data['price_amount'] = this.priceAmount;
    data['total_lesson_credits'] = this.totalLessonCredits;
    data['total_lesson_count'] = this.totalLessonCount;
    data['price_free'] = this.priceFree;
    data['image_name'] = this.imageName;
    data['image_url'] = this.imageUrl;
    data['chapter_priority'] = this.chapterPriority;
    data['is_favourite'] = this.isFavourite;
    data['tutorial_purchased_status'] = this.tutorialPurchasedStatus;
    if (this.chapters != null) {
      data['chapters'] = this.chapters.map((v) => v.toJson()).toList();
    }
    data['lesson_size_in_seconds'] = this.lessonSizeInSeconds;
    data['lesson_total_length'] = this.lessonTotalLength;
    return data;
  }
}

class OwnerDetails {
  String userId;
  int userType;

  OwnerDetails({this.userId, this.userType});

  OwnerDetails.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userType = json['user_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['user_type'] = this.userType;
    return data;
  }
}

class Chapters {
  String id;
  String chapterName;
  List<Lessons> lessons;
  String createdDate;

  Chapters({this.id, this.chapterName, this.lessons, this.createdDate});

  Chapters.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chapterName = json['chapter_name'];
    if (json['lessons'] != null) {
      lessons = new List<Lessons>();
      json['lessons'].forEach((v) {
        lessons.add(new Lessons.fromJson(v));
      });
    }
    createdDate = json['created_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['chapter_name'] = this.chapterName;
    if (this.lessons != null) {
      data['lessons'] = this.lessons.map((v) => v.toJson()).toList();
    }
    data['created_date'] = this.createdDate;
    return data;
  }
}

class Lessons {
  String lessonId;
  String lessonName;
  String length;
  String priceInCredits;
  String fileName;
  String fileUrl;
  int lessonPurchasedStatus;
  bool viewedStatus;
  int seconds;
  int priceFree;
  String merchantEnteredLessonPrice;
  String fileSizeInMb;
  String fileSizeEqualToPriceInMb;

  Lessons(
      {this.lessonId,
      this.lessonName,
      this.length,
      this.priceInCredits,
      this.fileName,
      this.fileUrl,
      this.lessonPurchasedStatus,
      this.viewedStatus,
      this.seconds,
      this.priceFree,
      this.merchantEnteredLessonPrice,
      this.fileSizeInMb,
      this.fileSizeEqualToPriceInMb});

  Lessons.fromJson(Map<String, dynamic> json) {
    lessonId = json['lesson_id'];
    lessonName = json['lesson_name'];
    length = json['length'];
    priceInCredits = json['price_in_credits'];
    fileName = json['file_name'];
    fileUrl = json['file_url'];
    lessonPurchasedStatus = json['lesson_purchased_status'];
    viewedStatus = json['viewed_status'];
    seconds = json['seconds'];
    priceFree = json['price_free'];
    merchantEnteredLessonPrice = json['merchant_entered_lesson_price'];
    fileSizeInMb = json['file_size_in_mb'];
    fileSizeEqualToPriceInMb = json['file_size_equal_to_price_in_mb'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lesson_id'] = this.lessonId;
    data['lesson_name'] = this.lessonName;
    data['length'] = this.length;
    data['price_in_credits'] = this.priceInCredits;
    data['file_name'] = this.fileName;
    data['file_url'] = this.fileUrl;
    data['lesson_purchased_status'] = this.lessonPurchasedStatus;
    data['viewed_status'] = this.viewedStatus;
    data['seconds'] = this.seconds;
    data['price_free'] = this.priceFree;
    data['merchant_entered_lesson_price'] = this.merchantEnteredLessonPrice;
    data['file_size_in_mb'] = this.fileSizeInMb;
    data['file_size_equal_to_price_in_mb'] = this.fileSizeEqualToPriceInMb;
    return data;
  }
}
