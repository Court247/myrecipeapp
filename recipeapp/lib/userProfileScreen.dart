import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<FirebaseAuth>(context);
    final User? user = auth.currentUser;
    const String defaultPhoto =
        'https://firebasestorage.googleapis.com/v0/b/recipeapp-3ab43.appspot.com/o/images%2Fno-user-image.gif?alt=media&token=25a43660-490e-438d-b1c7-ad6f8c122f7d';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: FutureBuilder(
        future: getUserData(user!.uid),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            //loading indicator while data gets displayed
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // after fetching user data, store it in userData
            final userData = snapshot.data ?? {};
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    //we could add an image to the user profile
                    //so this screen looks better
                    backgroundImage:
                        NetworkImage(userData['profileImage'] ?? defaultPhoto),
                  ),
                  const SizedBox(height: 20),
                  Text('Email: ${user.email}'),
                  Text('Location: ${userData['location']}'),
                  Text('Username: ${userData['username']}'),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  //get user data from Firestore
  Future<Map<String, dynamic>> getUserData(String uid) async {
    try {
      var querySnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      var uData = querySnapshot.data() ?? {};
      print(uData);
      return uData;
    } catch (e) {
      print('Error fetching user data: $e');
      return {};
    }
  }
}
