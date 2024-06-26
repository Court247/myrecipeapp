import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'createaccount.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'favoriteProvider.dart';
import 'optionpage.dart';
import 'postprovider.dart';

//This main page where the LOGIN is going to take place
Future<void> main() async {
  //this is the firebase configuration
  WidgetsFlutterBinding.ensureInitialized();
  String apiKey = 'AIzaSyAZ4KxmNjRzXwJM9utexG9p9PV31MnrLX8';
  String appId = '1:366937079655:android:9b70633b05d073c7edf9c2';
  String messagingSenderId = '366937079655';
  String projectId = 'recipeapp-3ab43';
  String storageBucket = 'recipeapp-3ab43.appspot.com';

  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
          storageBucket: storageBucket));

  runApp(const Login());
}

class Login extends StatelessWidget {
  const Login({super.key});

  //this MultiProvider initializes the provider so that a new instance doesn't have to be created
  //throughout the app and all information can be accessed from anywhere
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuth>(
          create: (context) => FirebaseAuth.instance,
        ),
        Provider<FirebaseFirestore>(
          create: (context) => FirebaseFirestore.instance,
        ),
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
        ChangeNotifierProvider(create: (context) => PostProvider()),
        Provider<FirebaseStorage>(create: (context) => FirebaseStorage.instance)
      ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: const LoginPage(),
      ),
    ); 
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormFieldState<String>> _user = GlobalKey();
  final GlobalKey<FormFieldState<String>> _pass = GlobalKey();

  //validates the user input to make sure it's not null
  submit() {
    final isValid = _user.currentState?.validate();
    final isValids = _pass.currentState?.validate();
    if (!isValid! || !isValids!) {
      return false;
    }
    _user.currentState?.save();
    _pass.currentState?.save();
    return true;
  }

  //gets the values from the user input make sure it's correct
  get values => {
        'Email': _user.currentState?.value,
        'Password': _pass.currentState?.value
      };

  //login function that checks if the user is in the database
  Future<bool?> login() async {
    //the auth and db variables are used to access the firebase authentication and firestore
    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    String message = '';

    //try catch block checks if the user is in the database and if not it will throw an error
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: _user.currentState!.value!,
        password: _pass.currentState!.value!,
      );

      User? user = userCredential.user;

      if (user != null) {
        print('Login Successful!');
        print('User ID: ${user.uid}');
        print('Email: ${user.email}');

        return true;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print(e.code);
        message = 'No user found for that email.';
        print(e.code);
      } else if (e.code == 'wrong-password') {
        print(e.code);

        message = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        print(e.code);

        message = 'Invalid email';
      } else if (e.code == 'too-many-requests') {
        print(e.code);

        message = 'Too many requests';
      } else if (e.code == 'email-already-in-use') {
        print(e.code);

        message = 'Email already in use';
      } else if (e.code == 'weak-password') {
        print(e.code);

        message = 'The password provided is too weak.';
      } else if (e.code == 'invalid-credential') {
        print(e.code);

        message = 'Invalid email.';
      } else {
        print(e.code);

        message = 'Invalid email or password.';
      }

      //if user is not in the database then it will display an error message
      //via snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ));
    } catch (e) {
      //print('here: ${e.toString()}');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/homepage_wallpaper.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color:
                      Color.fromRGBO(255, 255, 255, 0.8), // transparent white
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  children: <Widget>[
                    DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 50.0,
                        color: Colors.red,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          WavyAnimatedText('Flavor'),
                        ],
                        isRepeatingAnimation: true,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      key: _user,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        icon: Icon(Icons.email, color: Colors.black54),
                        hintStyle: TextStyle(color: Colors.black54),
                      ),
                      style: TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Email is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      key: _pass,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        icon: Icon(Icons.lock, color: Colors.black54),
                        hintStyle: TextStyle(color: Colors.black54),
                      ),
                      style: TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20.0),
                    //this is the login button
                    ElevatedButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all(const StadiumBorder()),
                          textStyle: MaterialStateProperty.all(
                              const TextStyle(fontSize: 35)),
                          fixedSize:
                              MaterialStateProperty.all(const Size(150, 50))),
                      onPressed: () async {
                        if (submit() && await login.call() == true) {
                          print(values);
                          if (mounted) {
                            //this will take the user to the option page
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const OptionPage()));
                          }
                        }
                      },
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 20.0),
                    //This is the create account button

                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.grey),
                          shape:
                              MaterialStateProperty.all(const StadiumBorder()),
                          fixedSize:
                              MaterialStateProperty.all(const Size(150, 50))),
                      onPressed: () {
                        //takes the user to the create account page
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CreateAccount()));
                      },
                      child: const Text(
                        'Create Account',
                        style: TextStyle(color: Colors.black, fontSize: 17),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
