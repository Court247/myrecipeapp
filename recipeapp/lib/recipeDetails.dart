import 'package:flutter/material.dart';

class recipeDetails extends StatelessWidget {
  final Map<String, dynamic> recipe;

  recipeDetails(this.recipe);

  @override
  Widget build(BuildContext context) {
    final List<dynamic> ingredients = recipe['ingredients'];
    final List<dynamic> steps = recipe['steps'];
    String ifnull =
        'https://firebasestorage.googleapis.com/v0/b/recipeapp-3ab43.appspot.com/o/images%2F1000_F_251955356_FAQH0U1y1TZw3ZcdPGybwUkH90a3VAhb.jpg?alt=media&token=091b00f6-a4a8-4a4a-b66f-60e8978fb471&_gl=1*1dfhnga*_ga*MTM5MTUxODI4My4xNjk4NTE4MjUw*_ga_CW55HF8NVT*MTY5OTM1MTA4OS40MS4xLjE2OTkzNTQ2MzMuMTAuMC4w';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          recipe['recipeName']?.toString()?.toUpperCase()?.trim() ?? ' ',
        ),
      ),
<<<<<<< HEAD
      body: Center(
        child: Column(
          children: [
            Text(recipe['recipeName'], style: const TextStyle(fontSize: 50)),
            Image.network(
              recipe['image'],
              fit: BoxFit.cover,
            ),
            
            // Display ingredients and steps side by side
            Row(
              children: [
                // Ingredients on the left
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
=======
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Image.network(
                recipe['image'] ?? ifnull,
                fit: BoxFit.cover,
              ),
              // Display recipe description, ingredients, and steps
              Column(
                children: [
                  // Recipe Description
                  Text(
                    '',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    recipe['description'] ?? 'No description available',
                    style: TextStyle(fontSize: 16),
                  ),
                  // Ingredients
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
>>>>>>> main
                    children: [
                      Text('Ingredients:',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          )),
                      for (var ingredient in ingredients) Text(ingredient),
                    ],
                  ),
                  // Steps
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Steps:',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          )),
                      for (var i = 0; i < steps.length; i++)
                        Text('${i + 1}. ${steps[i]}'),
                    ],
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
