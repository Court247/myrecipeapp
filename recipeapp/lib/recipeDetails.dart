import 'package:flutter/material.dart';

class RecipeDetails extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetails(this.recipe, {super.key});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> ingredients = recipe['ingredients'];
    final List<dynamic> steps = recipe['steps'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Details'),
      ),
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
                    children: [
                      const Text('Ingredients:',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                      for (var ingredient in ingredients) Text(ingredient),
                    ],
                  ),
                ),
                // Steps on the right
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Steps:',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                      for (var step in steps) Text(step),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
