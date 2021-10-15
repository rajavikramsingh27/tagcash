
class DatingProfileDetails {
  ProfileDetails profileDetails;

  DatingProfileDetails ({this.profileDetails});

  DatingProfileDetails .fromJson(Map<String, dynamic> json) {
    profileDetails = new ProfileDetails.fromJson(json);

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.profileDetails != null) {
      data['profile_details'] = this.profileDetails.toJson();
    }
    return data;
  }
}

class ProfileDetails {
  String id;
  String nickName;
  String occupation;
  String dob;
  String   age;
  int countryId;
  int cityId;
  int genderId;
  String description;
  PrivacySettings privacySettings;
  NotificationSettings notificationSettings;
  List<UploadedImages> uploadedImages;
  ProfileDetails({this.id,
    this.nickName,
    this.occupation,
    this.dob,
    this.age,
    this.countryId,
    this.cityId,
    this.genderId,
    this.description,
    this.privacySettings,
    this.notificationSettings,
    this.uploadedImages,
  });

  ProfileDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nickName= json['nick_name'];
    occupation= json['occupation'];
    dob = json['dob'];
    age = json['age'];
    countryId = json['country_id'];
    cityId = json['city_id'];
    genderId = json['gender_id'];
    description = json['description'];
    privacySettings = json['privacy_settings'] != null
        ? new PrivacySettings.fromJson(json['privacy_settings'])
        : null;
    notificationSettings = json['notification_settings'] != null
        ? new NotificationSettings.fromJson(json['notification_settings'])
        : null;
    if (json['uploaded_images'] != null) {
      uploadedImages = new List<UploadedImages>();
      json['uploaded_images'].forEach((v) {
        uploadedImages.add(new UploadedImages.fromJson(v));
      });
    }
    print(id);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nickname'] = this.nickName;
    data['occupation'] = this.occupation;
    data['dob'] = this.dob;
    data['age'] = this.age;
    data['country_id'] = this.countryId;
    data['city_id'] = this.cityId;
    data['gender_id'] = this.genderId;
    data['description'] = this.description;
    if (this.privacySettings != null) {
      data['privacy_settings'] = this.privacySettings.toJson();
    }
    if (this.notificationSettings != null) {
      data['notification_settings'] = this.notificationSettings.toJson();
    }
    if (this.uploadedImages != null) {
      data['uploaded_images'] =
          this.uploadedImages.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
class PrivacySettings {
  int maleStatus;
  int femaleStatus;
  int tgStatus;
  PrivacySettings({this.maleStatus, this.femaleStatus, this.tgStatus});

  PrivacySettings.fromJson(Map<String, dynamic> json) {
    maleStatus = json['male_status'];
    femaleStatus = json['female_status'];
    tgStatus = json['tg_status'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['male_status'] = this.maleStatus;
    data['female_status'] = this.femaleStatus;
    data['tg_status'] = this.tgStatus;

    return data;
  }
}

class NotificationSettings {
  int profileVisits;
  int receiveNewmessageStatus;
  int emailStatus;

  NotificationSettings(
      {
        this.profileVisits,
        this. receiveNewmessageStatus,
        this.emailStatus
      });

  NotificationSettings.fromJson(Map<String, dynamic> json) {
    profileVisits = json['profile_visits'];
    receiveNewmessageStatus = json['receive_newmessage_status'];
    emailStatus = json['email_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['profile_visits'] = this.profileVisits;
    data['receive_newmessage_status'] = this. receiveNewmessageStatus;
    data['email_status'] = this.emailStatus;
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
      {
        this.id,
        this.imageName,
        this.imageFileName,
        this.mainStatus,
        this.uploadedDate
      }
      );

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