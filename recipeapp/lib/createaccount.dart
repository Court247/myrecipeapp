import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

class CreateAccount extends StatelessWidget {
  const CreateAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const CreateAccountPage(),
    );
  }
}

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final GlobalKey<FormFieldState<String>> _email = GlobalKey();
  final GlobalKey<FormFieldState<String>> _pass = GlobalKey();
  final GlobalKey<FormFieldState<String>> _user = GlobalKey();
  String? _loc;
  var locations;
  String docLoc =
      'https://firebasestorage.googleapis.com/v0/b/recipeapp-3ab43.appspot.com/o/files%2FCityStates.txt?alt=media&token=111b4e06-edd9-4ce3-bd40-3d1356d2ed4b';
  @override
  initState() {
    super.initState();
    locations = locationsList();
  }

  locationsList() async {
    final storage = Provider.of<FirebaseStorage>(context, listen: false);
    var newlist = [];
    var response = await http.get(Uri.parse(docLoc));

    var decode = json.decode(response.body);
    for (int i = 0; i < decode.length; i++) {
      newlist.add('${decode[i]['city']}, ${decode[i]['state']}');
    }

    return newlist;
  }

  success() {
    return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Account created successfully!'),
      backgroundColor: Colors.green,
    ));
  }

  createUser() async {
    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    final db = Provider.of<FirebaseFirestore>(context, listen: false);
    String message = '';
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: _email.currentState!.value!,
        password: _pass.currentState!.value!,
      );

      User? user = userCredential.user;
      user!.updateDisplayName(_user.currentState!.value!);

      if (user != null) {
        print('Successfully created an account!');
        print('User ID: ${user.uid}');
        print('Email: ${user.email}');
        db.collection('users').doc(user.uid).set({
          'username': _user.currentState!.value!,
          'email': _email.currentState!.value!,
          'favorites': [],
          'posts': [],
          'location': _loc,
        });
        success();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else {
        message = 'Invalid email or password.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      print(e);
    }
  }

  submit() {
    final isValid = _email.currentState?.validate();
    final isValids = _pass.currentState?.validate();
    final isValidss = _user.currentState?.validate();
    if (!isValid! || !isValids! || !isValidss!) {
      return false;
    }
    _user.currentState?.save();
    _pass.currentState?.save();
    _email.currentState?.save();
    return true;
  }

  get values => {
        'Email': _email.currentState?.value,
        'Password': _pass.currentState?.value,
        'Username': _user.currentState?.value
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 100.0),
                child: Text(
                  'Flavor',
                  style: TextStyle(
                    fontSize: 60.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Create your account',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            TextFormField(
              key: _user,
              decoration: const InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(fontSize: 20),
                hintText: 'ex. JohnDoe123',
                hintStyle: TextStyle(fontSize: 20),
                icon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Username is required';
                }
                return null;
              },
            ),
            TextFormField(
              key: _email,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(fontSize: 20),
                hintText: 'ex. johndoe123@yahoo.com',
                hintStyle: TextStyle(fontSize: 20),
                icon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),
            TextFormField(
              key: _pass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(fontSize: 20),
                hintText: 'Enter your password',
                hintStyle: TextStyle(fontSize: 20),
                icon: Icon(Icons.lock),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),
            FutureBuilder<List<String>>(
              future: locations, // your Future<List<String>>
              builder:
                  (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.hasData) {
                  return DropdownButtonFormField<String>(
                    value: _loc,
                    icon: const Icon(Icons.arrow_downward),
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      labelStyle: TextStyle(fontSize: 20),
                      icon: Icon(Icons.location_on),
                    ),
                    items: snapshot.data!
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _loc = newValue;
                      });
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all(const StadiumBorder()),
                  textStyle:
                      MaterialStateProperty.all(const TextStyle(fontSize: 20)),
                  fixedSize: MaterialStateProperty.all(const Size(200, 0))),
              onPressed: () {
                print(values);
                createUser();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Login()));
              },
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
