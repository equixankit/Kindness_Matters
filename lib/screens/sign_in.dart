import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kindness_matters/screens/home.dart';
import 'package:kindness_matters/utils/image_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLogin = true;

  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      try {
        if (_isLogin) {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
        } else {
          UserCredential userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

          // Add the new user to the Firestore collection
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'name': _nameController.text,
            'email': _emailController.text,
            // You cannot store passwords in Firestore due to security reasons
          });
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          const SnackBar(content: Text("The password provided is too weak."));
        } else if (e.code == 'email-already-in-use') {
          const SnackBar(
              content: Text("The account already exists for that email."));
        } else if (e.code == 'network-request-failed') {
          const SnackBar(
              content: Text("A network error occurred. Please try again."));
        }
      } catch (e) {
        // print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Kindness Matters')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset(ImageConstant.signIn),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!_isLogin)
                          TextFormField(
                            controller: _nameController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                            decoration:
                                const InputDecoration(labelText: 'Name'),
                          ),
                        TextFormField(
                          controller: _emailController,
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                        TextFormField(
                          controller: _passwordController,
                          validator: (value) {
                            if (value!.isEmpty || value.length < 7) {
                              return 'Password must be at least 7 characters long';
                            }
                            return null;
                          },
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                        ),
                        if (!_isLogin)
                          TextFormField(
                            controller: _confirmPasswordController,
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                labelText: 'Confirm Password'),
                            obscureText: true,
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submit,
                          child: Text(_isLogin ? 'Login' : 'Sign Up'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(_isLogin
                              ? 'Create new account'
                              : 'Already have an account? Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
