

class MatchedProfileData {
  String profileId;
  String nickName;
  String  age;
  int genderId;
  int countryId;
  int cityId;
  String cityName;

  LastMessage lastMessage;
  String occupation;
  String description;
  List< UploadedImagesMatchedProfile> uploadedImages;

  MatchedProfileData(
      {this.profileId,
        this.nickName,
        this.age,
        this.genderId,
        this.countryId,
        this.cityId,
        this.cityName,
        this.occupation,
        this.description,
        this.uploadedImages,
        this.lastMessage});

  MatchedProfileData.fromJson(Map<String, dynamic> json) {
    profileId = json['profile_id'];
    nickName = json['nick_name'];
    age = json['age'];
    genderId = json['gender_id'];
    countryId = json['country_id'];
    cityId = json['city_id'];
    cityName = json['city_name'];
    occupation = json['occupation'];
    description = json['description'];
    if (json['uploaded_images'] != null) {
      uploadedImages = new List< UploadedImagesMatchedProfile>();
      json['uploaded_images'].forEach((v) {
        uploadedImages.add(new  UploadedImagesMatchedProfile.fromJson(v));
      });
    }
    lastMessage = json['last_message'] != null
        ? new LastMessage.fromJson(json['last_message'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['profile_id'] = this.profileId;
    data['nick_name'] = this.nickName;
    data['age'] = this.age;
    data['gender_id'] = this.genderId;
    data['country_id'] = this.countryId;
    data['city_id'] = this.cityId;
    data['city_name'] = this.cityName;
    data['occupation'] = this.occupation;
    data['description'] = this.description;
    if (this.uploadedImages != null) {
      data['uploaded_images'] = this.uploadedImages.map((v) => v.toJson()).toList();
    }
    if (this.lastMessage != null) {
      data['last_message'] = this.lastMessage.toJson();
    }
    return data;
  }
}

class UploadedImagesMatchedProfile {
  int id;
  String imageName;
  String imageFileName;
  int mainStatus;
  String uploadedDate;

  UploadedImagesMatchedProfile(
      {this.id,
        this.imageName,
        this.imageFileName,
        this.mainStatus,
        this.uploadedDate});

  UploadedImagesMatchedProfile.fromJson(Map<String, dynamic> json) {
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
class LastMessage {
  String messageType;
  String message;

  LastMessage({this.messageType, this.message});

  LastMessage.fromJson(Map<String, dynamic> json) {
    messageType = json['message_type'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message_type'] = this.messageType;
    data['message'] = this.message;
    return data;
  }
}