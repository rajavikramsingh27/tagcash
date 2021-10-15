class AlbumDetails {
  String id;
  String filesCount;
  String albumName;
  String visibility;
  String visibilityName;
  String createdDate;
  String memberType;
  String membershipStatus;

  AlbumDetails({
    this.id,
    this.filesCount,
    this.albumName,
    this.visibility,
    this.createdDate,
    this.visibilityName,
    this.memberType,
    this.membershipStatus,
  });

  AlbumDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    filesCount = json['files_count'];
    albumName = json['album_name'];
    visibility = json['visibility'];
    createdDate = json['created_date'];
    visibilityName = json['visibility_name'];
    memberType = json['member_type'];
    membershipStatus = json['membership_status'];
  }
}
