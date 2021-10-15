import 'package:tagcash/apps/newsfeed/models/comment_reply.dart';

class Comment {
  String news_feed_comment_id;
  String news_feed_id;
  String news_feed_comment;
  String total_likes;
  String total_comment_likes;
  String comment_date;
  String is_comment_like;
  var owner;
  List<CommentReply> reply_by_user;

  Comment(
      {this.news_feed_comment_id,
        this.news_feed_id, this.news_feed_comment, this.total_likes,this.total_comment_likes, this.comment_date,  this.is_comment_like, this.owner});

  Comment.fromJson(Map<String, dynamic> json) {
    news_feed_comment_id = json['news_feed_comment_id'].toString();
    news_feed_id = json['news_feed_id'].toString();
    news_feed_comment = json['news_feed_comment'].toString();
    total_likes = json['total_likes'].toString();
    total_comment_likes = json['total_comment_likes'].toString();
    comment_date = json['comment_date'].toString();
    is_comment_like = json['is_comment_like'].toString();
    if(json['comment_owner'] != '' && json['comment_owner'] != null){
      owner = json['comment_owner'];
    }
    if(json['reply_by_user'] != '' && json['reply_by_user'] != null){
      var tagObjsJson = json['reply_by_user'] as List;
      reply_by_user = tagObjsJson.map<CommentReply>((json) {
        return CommentReply.fromJson(json);
      }).toList();
    }
  }

}
