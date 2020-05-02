import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

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
  // 197: bool for whether to show spinner
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 197: wrap body in modal, use showSpinner bool (true) in async methods to trigger the spinner
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
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
                  // 197: Trigger showSPinner bool while this is running 
                  // (needs SetState to call build method again)
                  setState(() {
                    showSpinner = true;
                  });                  
                  // 195: create user with email & password using _auth instance
                  // Returns a Future which we store in a final variable
                  // This might go wrong, so try & catch             
                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                    // If something gets returned, forward user to the chat screen
                    if (newUser != null) {
                      Navigator.pushNamed(context, ChatScreen.id);
                    }
                    // 197: Stop the spinner
                    setState(() {
                      showSpinner = false;
                    });
                  } catch (e) {
                    print(e);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
