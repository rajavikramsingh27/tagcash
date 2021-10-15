class AlbumContent {
  String id;
  String userId;
  String userType;
  String albumId;
  String photoName;
  String photoNotes;
  String priceWalletId;
  String priceAmount;
  String viewsCount;
  String favCount;
  String fileName;
  String fileUrl;
  String createdDate;
  String uploadType;
  String thumbnail;
  String albumContent;
  bool memberStatus;
  bool permittedToView;
  bool unlockedStatus;

  AlbumContent({
    this.id,
    this.userId,
    this.userType,
    this.albumId,
    this.photoName,
    this.photoNotes,
    this.priceWalletId,
    this.priceAmount,
    this.viewsCount,
    this.favCount,
    this.fileName,
    this.fileUrl,
    this.createdDate,
    this.uploadType,
    this.thumbnail,
    this.albumContent,
    this.memberStatus,
    this.permittedToView,
    this.unlockedStatus,
  });

  AlbumContent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userType = json['user_type'];
    albumId = json['album_id'];
    photoName = json['photo_name'];
    photoNotes = json['photo_notes'];
    priceWalletId = json['price_wallet_id'];
    priceAmount = json['price_amount'];
    viewsCount = json['views_count'];
    favCount = json['fav_count'];
    fileName = json['file_name'];
    fileUrl = json['file_url'];
    uploadType = json['upload_type'];
    createdDate = json['created_date'];
    thumbnail = json['thumbnail'];
    albumContent = json['album_content'];
    memberStatus = json['member_status'];
    permittedToView = json['permission_to_view'];
    unlockedStatus = json['unlocked_status'];
  }
}
