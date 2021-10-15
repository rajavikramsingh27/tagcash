class FavouriteProfileDetailsData {
  String id;
  OwnerDetails ownerDetails;
  String nickName;
  Null gender;
  String dob;
  String  age;
  int countryId;
  String countryName;
  int cityId;
  String cityName;
  int genderId;
  String occupation;
  String description;
  List<ProfileDetailUploadedImages> uploadedImages;
  int favouriteStatus;
  int blockedStatus;
  List<Notes> notes;
  String createdDate;
  DateDiff dateDiff;

  FavouriteProfileDetailsData(
      {this.id,
        this.ownerDetails,
        this.nickName,
        this.gender,
        this.dob,
        this.age,
        this.countryId,
        this.countryName,
        this.cityId,
        this.cityName,
        this.genderId,
        this.occupation,
        this.description,
        this.uploadedImages,
        this.favouriteStatus,
        this.blockedStatus,
        this.notes,
        this.createdDate,
        this.dateDiff});

  FavouriteProfileDetailsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ownerDetails = json['ownerDetails'] != null
        ? new OwnerDetails.fromJson(json['ownerDetails'])
        : null;
    nickName = json['nick_name'];
    gender = json['gender'];
    dob = json['dob'];
    age = json['age'];
    countryId = json['country_id'];
    countryName = json['country_name'];
    cityId = json['city_id'];
    cityName = json['city_name'];
    genderId = json['gender_id'];
    occupation = json['occupation'];
    description = json['description'];
    if (json['uploaded_images'] != null) {
      uploadedImages = new List<ProfileDetailUploadedImages>();
      json['uploaded_images'].forEach((v) {
        uploadedImages.add(new ProfileDetailUploadedImages.fromJson(v));
      });
    }
    favouriteStatus = json['favourite_status'];
    blockedStatus = json['blocked_status'];
    if (json['notes'] != null) {
      notes = new List<Notes>();
      json['notes'].forEach((v) {
        notes.add(new Notes.fromJson(v));
      });
    }
    createdDate = json['created_date'];
    dateDiff = json['date_diff'] != null
        ? new DateDiff.fromJson(json['date_diff'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.ownerDetails != null) {
      data['ownerDetails'] = this.ownerDetails.toJson();
    }
    data['nick_name'] = this.nickName;
    data['gender'] = this.gender;
    data['dob'] = this.dob;
    data['age'] = this.age;
    data['country_id'] = this.countryId;
    data['country_name'] = this.countryName;
    data['city_id'] = this.cityId;
    data['city_name'] = this.cityName;
    data['gender_id'] = this.genderId;
    data['occupation'] = this.occupation;
    data['description'] = this.description;
    if (this.uploadedImages != null) {
      data['uploaded_images'] =
          this.uploadedImages.map((v) => v.toJson()).toList();
    }
    data['favourite_status'] = this.favouriteStatus;
    data['blocked_status'] = this.blockedStatus;
    if (this.notes != null) {
      data['notes'] = this.notes.map((v) => v.toJson()).toList();
    }
    data['created_date'] = this.createdDate;
    if (this.dateDiff != null) {
      data['date_diff'] = this.dateDiff.toJson();
    }
    return data;
  }
}

class OwnerDetails {
  String  userId;
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

class ProfileDetailUploadedImages {
  int id;
  String imageName;
  String imageFileName;
  int mainStatus;
  String uploadedDate;

  ProfileDetailUploadedImages(
      {this.id,
        this.imageName,
        this.imageFileName,
        this.mainStatus,
        this.uploadedDate});

  ProfileDetailUploadedImages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    imageName = json['image_name'];
    imageFileName = json['image_file_name'];
    mainStatus = json['main_status'];
    uploadedDate = json['uploaded_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image_name'] = this.imageName;
    data['image_file_name'] = this.imageFileName;
    data['main_status'] = this.mainStatus;
    data['uploaded_date'] = this.uploadedDate;
    return data;
  }
}

class Notes {
  String sId;
  String note;
  String createdDate;

  Notes({this.sId, this.note, this.createdDate});

  Notes.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    note = json['note'];
    createdDate = json['created_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['note'] = this.note;
    data['created_date'] = this.createdDate;
    return data;
  }
}
class DateDiff {
  int totalDays;
  int years;
  int months;
  int days;
  int hours;
  int minutes;
  int seconds;

  DateDiff({this.totalDays,
    this.years,
    this.months,
    this.days,
    this.hours,
    this.minutes,
    this.seconds});

  DateDiff.fromJson(Map<String, dynamic> json) {
    totalDays = json['total_days'];
    years = json['years'];
    months = json['months'];
    days = json['days'];
    hours = json['hours'];
    minutes = json['minutes'];
    seconds = json['seconds'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_days'] = this.totalDays;
    data['years'] = this.years;
    data['months'] = this.months;
    data['days'] = this.days;
    data['hours'] = this.hours;
    data['minutes'] = this.minutes;
    data['seconds'] = this.seconds;
    return data;
  }
}