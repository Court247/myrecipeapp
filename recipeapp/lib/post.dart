import 'Recipe.dart';
import 'package:firebase_auth/firebase_auth.dart';

//THis is the post class i'm not sure if it's necessary but i added it to keep track of the user who posted the recipe
//and the recipe itself
class Post {
<<<<<<< HEAD
  String posterID;
=======
  String? posterID;
>>>>>>> 7690943c0cf17ccc4f5add9b6371edeed53ee75e
  User? poster;
  Recipe posts;
  int isLiked = 0;
  int isDisliked = 0;

<<<<<<< HEAD
  Post({required this.posterID, this.poster, required this.posts});
=======
  Post({required this.poster, required this.posts, this.posterID});
>>>>>>> 7690943c0cf17ccc4f5add9b6371edeed53ee75e

//this is the method that converts the json data to a recipe object
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
<<<<<<< HEAD
      posterID: json['poster'],
=======
      posterID: json['posterID'],
      poster: json['poster'],
>>>>>>> 7690943c0cf17ccc4f5add9b6371edeed53ee75e
      posts: Recipe.fromJson(json['posts']),
    );
  }

  factory Post.fromJson2(User? jsonPoster, Map<String, dynamic> jsonPosts) {
    return Post(
      posterID: jsonPoster!.uid,
<<<<<<< HEAD
      //poster: jsonPoster,
      posts: Recipe.fromJson(jsonPosts),
    );
  }
=======
      poster: jsonPoster,
      posts: Recipe.fromJson(jsonPosts),
    );
  }

>>>>>>> 7690943c0cf17ccc4f5add9b6371edeed53ee75e
  Map<String, dynamic> toJson() {
    return {
      'posterID': posterID,
      'posts': posts.toJson(),
    };
  }
}
