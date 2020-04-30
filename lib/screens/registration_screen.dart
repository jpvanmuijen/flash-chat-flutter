import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'Register';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // 195 create variables voor useremail, password and Firebase auth instance
  String email;
  String password;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 185: wrap with Hero widget and give it the same tag as Welcome screen
            Hero(
              tag: 'logo',
              child: Container(
                height: 200.0,
                child: Image.asset('images/logo.png'),
              ),
            ),
            SizedBox(
              height: 48.0,
            ),
            TextField(
              textAlign: TextAlign.center,
              // 195: change keyboard type for email address
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                // 195: Store email value
                email = value;
              },
              decoration: kTextFieldDecoration.copyWith(
                hintText: 'Enter your email',
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
              // 195: obscure password
              obscureText: true,
              textAlign: TextAlign.center,
              onChanged: (value) {
                // 195: Store password value
                password = value;
              },
              decoration: kTextFieldDecoration.copyWith(
                hintText: 'Enter your password',
              ),
            ),
            SizedBox(
              height: 24.0,
            ),
            RoundedButon(
              text: 'Register',
              color: Colors.blueAccent,
              // 195: CreateUser returns a Future, so we have to wait for the result
              onPressed: () async {
                // 195: create user with email & password using _auth instance
                // Returns a Future which we store in a final variable
                // This might go wrong, so try & catch
                try {
                  final newUser = await _auth.createUserWithEmailAndPassword(
                      email: email, password: password);
                      // If something gets returned, forward user to the chat screen
                      if(newUser != null) {
                        Navigator.pushNamed(context, ChatScreen.id);
                      }
                } catch (e) {
                  print(e);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
