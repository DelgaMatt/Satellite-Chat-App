import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satellite/provider/dark_mode_provider.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:satellite/widgets/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredUsername = '';
  var _enteredPassword = '';
  File? _selectedImage;
  var _isAuthenticating = false;

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || !_isLogin && _selectedImage == null) {
      // show error message..
      return;
    }

    _formKey.currentState!.save();
    // allows us the ability to add the onSaved function

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        // final userCredentials =
        await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');
        //referemce of firebase cloud storage - storing image to the firebase cloud

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        // ..
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication Failed'),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
  var darkMode = ref.watch(darkModeProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Theme.of(context).colorScheme.primary.withOpacity(0.8),
          Theme.of(context).colorScheme.primary.withOpacity(0.6),
        ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    top: 30,
                    bottom: 0,
                    left: 20,
                    right: 20,
                  ),
                  width: 400,
                  child: darkMode ? Image.asset('lib/assets/images/satellite_dark.png') : Image.asset('lib/assets/images/satellite_light.png'),
                ),
                Card(
                  color: darkMode ? const Color.fromARGB(255, 23, 23, 23) : Theme.of(context).colorScheme.background,
                  // shadowColor: Color.fromARGB(255, 221, 162, 13),
                  elevation: 2.0,
                  margin: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(40)),
                    side: BorderSide(color: Theme.of(context).colorScheme.secondary)
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isLogin)
                              UserImagePicker(
                                onPickImage: (pickedImage) {
                                  _selectedImage = pickedImage;
                                },
                              ),
                            TextFormField(
                              style: darkMode? TextStyle(color: Theme.of(context).colorScheme.onPrimary) : TextStyle(color: Theme.of(context).colorScheme.primary),
                              decoration: InputDecoration(
                                  labelText: 'Email Address',
                                  floatingLabelStyle: darkMode? TextStyle(color: Theme.of(context).colorScheme.secondary) : TextStyle(color: Theme.of(context).colorScheme.primary),
                                  ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredEmail = value!;
                              },
                            ),
                            if (!_isLogin)
                              TextFormField(
                                    style: darkMode? TextStyle(color: Theme.of(context).colorScheme.onPrimary) : TextStyle(color: Theme.of(context).colorScheme.primary),                                
                                    decoration: InputDecoration(
                                      labelText: 'Username',
                                      floatingLabelStyle: darkMode ? TextStyle(color: Theme.of(context).colorScheme.secondary) : TextStyle(color: Theme.of(context).colorScheme.primary),
                                    ),
                                enableSuggestions: false,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim().length < 4) {
                                    return 'Please enter at least 4 characters';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredUsername = value!;
                                },
                              ),
                            TextFormField(
                                  style: darkMode? TextStyle(color: Theme.of(context).colorScheme.onPrimary) : TextStyle(color: Theme.of(context).colorScheme.primary),                              
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    floatingLabelStyle: darkMode? TextStyle(color: Theme.of(context).colorScheme.secondary) : TextStyle(color: Theme.of(context).colorScheme.primary),
                                  ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Password must be at least 6 characters long.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredPassword = value!;
                              },
                            ),
                            const SizedBox(height: 12),
                            if (_isAuthenticating)
                              const CircularProgressIndicator(),
                            if (!_isAuthenticating)
                              ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                                child: Text(_isLogin ? 'Login' : 'Signup'),
                              ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? 'Create an Account'
                                  : 'I already have an account'),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
