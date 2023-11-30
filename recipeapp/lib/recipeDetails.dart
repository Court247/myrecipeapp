import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShowRecipesDetails extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final int index;
  ShowRecipesDetails({required this.recipe, super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            recipe['recipeName'],
            style: GoogleFonts.lato(),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ShowRecipeDetails(
          recipe: recipe,
          index: index,
        ),
      ),
    );
  }
}

class ShowRecipeDetails extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final int index;
  ShowRecipeDetails({required this.recipe, super.key, required this.index});

  @override
  State<ShowRecipeDetails> createState() => _RecipeDetails(recipe: recipe);
}

class _RecipeDetails extends State<ShowRecipeDetails> {
  final Map<String, dynamic> recipe;

  _RecipeDetails({required this.recipe});
  //This is the author of the recipe
  _postAuthor() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: userData != null
              ? NetworkImage(userData['profileImage'] ?? defaultPhoto)
              : NetworkImage(defaultPhoto),
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userData['username'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  getFutureBuilder() {
    return FutureBuilder<DocumentSnapshot>(
      future: db.collection('users').doc(post.posterID).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          userData = snapshot.data!.data() as Map<String, dynamic>;

          return _postAuthor();
        }

        return const CircularProgressIndicator();
      },
    );
  }

  update() async {
    print(index);
    await db.collection('posts').doc((index + 1).toString()).update({
      'likedCount': post.likedCount,
      'dislikedCount': post.dislikedCount,
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> ingredients = recipe['ingredients'];
    final List<dynamic> steps = recipe['steps'];
    String ifnull =
        'https://firebasestorage.googleapis.com/v0/b/recipeapp-3ab43.appspot.com/o/images%2F1000_F_251955356_FAQH0U1y1TZw3ZcdPGybwUkH90a3VAhb.jpg?alt=media&token=091b00f6-a4a8-4a4a-b66f-60e8978fb471&_gl=1*1dfhnga*_ga*MTM5MTUxODI4My4xNjk4NTE4MjUw*_ga_CW55HF8NVT*MTY5OTM1MTA4OS40MS4xLjE2OTkzNTQ2MzMuMTAuMC4w';

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              //getFutureBuilder(),
              Image.network(
                recipe['image'] ?? ifnull,
                fit: BoxFit.cover,
              ),
              // Display recipe description, ingredients, and steps
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Description
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Lato',
                          ),
                        ),
                        Text(
                          recipe['description'] ?? 'No description available',
                          style: GoogleFonts.lato(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  // Ingredients
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ingredients:',
                            style: GoogleFonts.lato(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            )),
                        SizedBox(
                          width: 360,
                          child: Divider(
                            thickness: 4,
                            color: Colors.red[500],
                            height: 5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (var ingredient in ingredients)
                          Text(ingredient, style: GoogleFonts.lato()),
                      ],
                    ),
                  ),
                  // Steps
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Instructions:',
                            style: GoogleFonts.lato(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            )),
                        Container(
                          width: 360,
                          child: Divider(
                            thickness: 4,
                            color: Colors.red[500],
                            height: 5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (var i = 0; i < steps.length; i++)
                          Text(
                            '${i + 1}. ${steps[i]}',
                            style: GoogleFonts.lato(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
