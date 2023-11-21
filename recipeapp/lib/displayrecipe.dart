import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:favorite_button/favorite_button.dart';

import 'package:provider/provider.dart';
import 'addpost.dart';
import 'favoriteProvider.dart';

import 'post.dart';
import 'postprovider.dart';
import 'recipepage.dart';

//this is the page where the user can view the recipes as a timeline
//might change it to a list time so you can just click and it'll show who uploaded it and the recipe

class DisplayRecipe extends StatelessWidget {
  const DisplayRecipe({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const DisplayRecipePage(),
    );
  }
}

class DisplayRecipePage extends StatefulWidget {
  const DisplayRecipePage({super.key});

  @override
  State<DisplayRecipePage> createState() => _DisplayRecipeState();
}

class _DisplayRecipeState extends State<DisplayRecipePage> {
  final recipeSearch = TextEditingController();

  late List<Post> posts = [];
  late List<Post> recipes = [];
  late List<Post> recipeList = [];

  late final provider;
  late final db;
  late final auth;
  late var postData;
  var recipe;
  var data;
  String ifnull =
      'https://firebasestorage.googleapis.com/v0/b/recipeapp-3ab43.appspot.com/o/images%2F1000_F_251955356_FAQH0U1y1TZw3ZcdPGybwUkH90a3VAhb.jpg?alt=media&token=091b00f6-a4a8-4a4a-b66f-60e8978fb471&_gl=1*1dfhnga*_ga*MTM5MTUxODI4My4xNjk4NTE4MjUw*_ga_CW55HF8NVT*MTY5OTM1MTA4OS40MS4xLjE2OTkzNTQ2MzMuMTAuMC4w';

  //this is the method that will be called when the user taps on the bottom navigator
  @override
  void initState() {
    super.initState();
    provider = Provider.of<PostProvider>(context, listen: false);
    db = Provider.of<FirebaseFirestore>(context, listen: false);
    auth = Provider.of<FirebaseAuth>(context, listen: false);

    checkForPosts();
  }

  getData(String? postID) async {
    var data = await getUserData(postID);
    setState(() {
      postData = data;
    });
  }

  //gets the user data from the database
  getUserData(String? postID) async {
    try {
      var querySnapshot = await db.collection('users').doc(postID).get();
      var uData = querySnapshot.data()!;
      //print(uData);
      return uData;
    } catch (e) {
      print(e);
    }
  }

  checkForPosts() {
    db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        recipe = doc.data();
        setState(() {
          data = Post.fromJson(recipe);
          //this is to check if the recipe is already in the list
          if (!provider.posts
              .any((post) => post.posts.recipeName == data.posts.recipeName)) {
            provider.addPost(data);
          }

          recipes = provider.posts;

          recipeList = recipes;
        });
      });
    });
  }


  addToPostCollection() {
    for (int i = 0; i < recipeList.length; i++) {
      db
          .collection('posts')
          .doc((i + 1).toString())
          .set(recipeList[i].toJson());
    }
  }

//this is the like button
  _like(var post) {
    final favs = Provider.of<FavoritesProvider>(context, listen: false);
    final db = Provider.of<FirebaseFirestore>(context);
    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: FavoriteButton(
        iconColor: Colors.pinkAccent.shade400,
        iconSize: 35.5,
        isFavorite: post.posts.isFavorite,
        valueChanged: (fav) {
          post.posts.isFavorite = fav;
          if (fav) {
            post.posts.canAdd = false;
          }
          favs.addFav(post);
          List<Map<String, dynamic>> jsonList =
              favs.recipes.map((item) => item.posts.toJson()).toList();
          var authUser = auth.currentUser;
          db
              .collection('users')
              .doc(authUser!.uid)
              .update({'favorites': jsonList});
        },
      ),
    );
  }

  void searchRecipes(String query) {
    //Searches and creates new list of games that matches the query String
    //every time the text field is changed
    final suggestions = recipes.where((recipe) {
      final recipeName = recipe.posts.recipeName.toLowerCase();
      final input = query.toLowerCase();

      //return the instance that == the query String
      return recipeName.contains(input);
    }).toList();

    //sets the state back to gameList to refill the list of previous games
    setState(() => recipeList = suggestions);
  }

  Future<DocumentSnapshot> fetchUserData(var userID) async {
    var userDoc = await db.collection('users').doc(userID).get();
    return userDoc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //This button is to add recipes
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            //This is the button that will take you to the add recipe page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPosts()),
            );
          },
          child: const Icon(Icons.add)),
      body: Column(children: [
        SizedBox(
          height: 35,
          child: TextFormField(
            controller: recipeSearch,
            decoration: InputDecoration(
                prefix: const Icon(Icons.search),
                hintText: 'Recipe Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.black),
                )),
            onChanged: searchRecipes,
          ),
        ),
        Expanded(
            child: ListView.builder(
          itemCount: recipeList.length,
          itemBuilder: (BuildContext context, int index) {
            var post = recipeList[index];
            return FutureBuilder<DocumentSnapshot>(
              future: fetchUserData(post.posterID),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  postData = snapshot.data!.data();
                  return ListTile(
                    leading: Image.network(
                      post.posts.image ?? ifnull,
                      fit: BoxFit.cover,
                    ),
                    title: Text(post.posts.recipeName),
                    subtitle: Text(postData['username']),
                    trailing: _like(post),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowRecipe(
                            post: post,
                            userData: postData,
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            );
          },
        )),
      ]),
    );
  }
}
