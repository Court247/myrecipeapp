import 'Recipe.dart';

//THis is the post class i'm not sure if it's necessary but i added it to keep track of the user who posted the recipe
//and the recipe itself
class Post {
  String? posterID;
  Recipe posts;
  String? location;

  bool isLiked = false;
  bool isDisliked = false;
  int likedCount = 0;
  int dislikedCount = 0;

  Post(
      {required this.posts,
      this.posterID,
      this.location,
      this.isLiked = false,
      this.isDisliked = false,
      this.likedCount = 0,
      this.dislikedCount = 0});

//this is the method that converts the json data to a recipe object
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      posterID: json['posterID'],
      posts: Recipe.fromJson(json['posts']),
    );
  }

  factory Post.fromJson2(String jsonPoster, Map<String, dynamic> jsonPosts) {
    return Post(
      posterID: jsonPoster,
      posts: Recipe.fromJson(jsonPosts),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posterID': posterID,
      'posts': posts.toJson(),
    };
  }
}
