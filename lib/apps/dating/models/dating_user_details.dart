class DatingUserDetails {
  String id;
  String nickName;
  String dob;
  int dobStrtime;
  int countryId;
  String countryName;
  int cityId;
  String cityName;
  int genderId;
  String occupation;
  String description;
  String age;

  int likedStatus;
  int hidedStatus;
  List<UploadedImages> uploadedImages;
  String  viewMyProfileOnly;
  int onlineStatus;

  DatingUserDetails(
      {this.id,
        this.nickName,
        this.dob,
        this.dobStrtime,
        this.countryId,
        this.cityId,
        this.countryName,
        this.cityName,
        this.genderId,
        this.occupation,
        this.description,
        this.age,

        this.likedStatus,
        this.hidedStatus,
        this.onlineStatus,
        this.uploadedImages,
        this.viewMyProfileOnly});

  DatingUserDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nickName = json['nick_name'];
    dob = json['dob'];
    dobStrtime = json['dob_strtime'];
    countryId = json['country_id'];
    cityId = json['city_id'];
    genderId = json['gender_id'];
    occupation = json['occupation'];
    description = json['description'];
    age = json['age'];
    likedStatus = json['liked_status'];
    hidedStatus = json['hided_status'];
    countryName=json['country_name'];
    cityName=json['city_name'];
    if (json['uploaded_images'] != null) {
      uploadedImages = new List<UploadedImages>();
      json['uploaded_images'].forEach((v) {
        uploadedImages.add(new UploadedImages.fromJson(v));
      });
    }
    viewMyProfileOnly = json['view_my_profile_only'];
    onlineStatus = json['online_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nick_name'] = this.nickName;
    data['dob'] = this.dob;
    data['dob_strtime'] = this.dobStrtime;
    data['country_id'] = this.countryId;
    data['city_id'] = this.cityId;
    data['gender_id'] = this.genderId;
    data['occupation'] = this.occupation;
    data['description'] = this.description;
    data['age'] = this.age;
    data['liked_status'] = this.likedStatus;
    data['hided_status'] = this.hidedStatus;
    data['country_name'] = this.countryName;
    data['city_name'] = this.cityName;
    if (this.uploadedImages != null) {
      data['uploaded_images'] =
          this.uploadedImages.map((v) => v.toJson()).toList();
    }
    data['view_my_profile_only'] = this.viewMyProfileOnly;
    data['online_status'] = this.onlineStatus;
    return data;
  }
}

class UploadedImages {
  int id;
  String imageName;
  String imageFileName;
  int mainStatus;
  String uploadedDate;

  UploadedImages(
      {this.id,
        this.imageName,
        this.imageFileName,
        this.mainStatus,
        this.uploadedDate});

  UploadedImages.fromJson(Map<String, dynamic> json) {
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