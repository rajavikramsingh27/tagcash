import 'package:tagcash/apps/newsfeed/models/comment.dart';

class NewsFeeds {
  String id;
  String news_feed_text;
  String total_comments;
  String total_likes;
  String is_pinned;
  String is_liked;
  var owner;
  List<String> images;
  List<String> videos;
  List<Comment> comment;
  bool isComment = false;

  NewsFeeds(this.id,
      this.news_feed_text, this.total_comments, this.total_likes, this.is_pinned, this.is_liked, this.owner, this.isComment, [this.images, this.videos, this.comment]);

  NewsFeeds.fromJson(Map<String, dynamic> json) {

    if(json['is_pinned'] == '1'){

    }
    id = json['id'].toString();
    news_feed_text = json['news_feed_text'].toString();
    total_comments = json['total_comments'].toString();
    total_likes = json['total_likes'].toString();
    is_pinned = json['is_pinned'].toString();
    is_liked = json['is_liked'].toString();
    if(json['owner'] != '' && json['owner'] != null){
      owner = json['owner'];
    }
    if(json['image_url'] != '' && json['image_url'] != null){
      var image = json['image_url'];
      images = new List<String>.from(image);
    } else{
      var image = "";
      images = new List<String>();
      images.add(image);
    }
    if(json['uploaded_videos'] != '' && json['uploaded_videos'] != null){
      var video = json['uploaded_videos'];
      videos = new List<String>.from(video);
    } else{
      var video = "";
      videos = new List<String>();
      videos.add(video);
    }
    if(json['comments'] != '' && json['comments'] != null){
      var tagObjsJson = json['comments'] as List;
      comment = tagObjsJson.map<Comment>((json) {
        return Comment.fromJson(json);
      }).toList();
    }
  }
}
