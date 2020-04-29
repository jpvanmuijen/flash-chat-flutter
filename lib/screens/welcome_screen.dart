import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:flash_chat/components/rounded_button.dart';

class WelcomeScreen extends StatefulWidget {
  // 182: create screen ID to refer to instead of a String
  // Make it static (modifier), so we can access it on the class instead of creating an entire object
  // Static properties are class-wide-variables, so universally available from the class
  // If you want a const value inside a class, you have to make it static
  // Methods inside classes can also be const
  static const String id = 'Welcome';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

// 'with SingleTickerProviderStateMixin' adds ticker capability to the State object
class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  // 186: Create animation controller + animation (curve) and initialize in initState
  AnimationController controller;
  Animation animation;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: 3000),
      // vsync is the ticker, usually the State object
      // 'this' keyword refers to the _WelcomScreenState object
      vsync: this,
    );
    // Set animation to controller and curve. Animation is on top of controller.

    // 186.1 Curved animation needs a max upperbound of 1
    // animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    // 186.2 Alternatively, set animation to be a color tween, .animate applies to a parent/controller
    animation =
        ColorTween(begin: Colors.red, end: Colors.blue).animate(controller);
    // Set the animation direction
    controller.forward();

    // 186: Add status listener to listen to and print out the animation status
    /*
    animation.addStatusListener((status) {
      print(status);
      // Depending on the direction of the AnimationStatus, pingpong
      if(status == AnimationStatus.completed) {
        controller.reverse(from:1.0);
      } else if(status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
    */
    // Listen to ticker, everytime it changes, have something happen
    controller.addListener(() {
      print(animation.value);
      // Use setState to update the screen and use the controller value
      setState(() {});
    });
  }

  // When dispose is called, also dispose of animation controllers to free resources
  @override
  void dispose() {
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 186.1 As a test, use the controller.value to change opacity
      // backgroundColor: Colors.red.withOpacity(controller.value),
      // 186.2 Use a color tween value as background color
      backgroundColor: animation.value,
      //backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                // 185: wrap elemenent in Hero widget to create animations and give it a tag
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    // 186.1 Use the animation value with curve to set a height (upperbound of max 1, so multiply)
                    // height: animation.value * 100,
                    height: 60,
                  ),
                ),
                // 188: animated text kit, prefab animations
                TypewriterAnimatedTextKit(
                  text: ['Flash Chat'],
                  textStyle: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                  isRepeatingAnimation: false,
                  speed: Duration(milliseconds: 200),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            // 189: moved RoundedButtons to its own class in components folder
            RoundedButon(
              text: 'Log in',
              color: Colors.lightBlueAccent,
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            RoundedButon(
              color: Colors.blueAccent,
              onPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
              text: 'Register',
            ),
          ],
        ),
      ),
    );
  }
}
