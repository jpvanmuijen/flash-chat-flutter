import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 202: Move Firestore to root, so we can access it from any widget
final _firestore = Firestore.instance;
// 203: Move user to root, so we can access it from Bubble widget
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'Chat';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // 195: Get user from Firebase using a FirebaseAuth instance, and create an empty user (203: moved to root)
  final _auth = FirebaseAuth.instance;

  // 198: Create variable to store message, and a Firestore instance (202: moved to top)
  String messageText;
  // 202: Create textController to clear message body on send
  final messageTextController = TextEditingController();

  void getCurrentUser() async {
    // 195: If someone is registered or logged in, currentUser() will have a value
    // Try to get it
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  // 199: Get messages from Firebase (manual method)
  /*
  void getMessages() async {
    // Returns a Future Querysnapshot
    final messages = await _firestore.collection('messages').getDocuments();
    // messages.documents returns a list, so we need a loop
    for(var message in messages.documents) {
      print(message.data);
    }
  }
  */
  // 199: Get messages via Stream
  // Calling this method at any point subscribes to this stream
  void messagesStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.documents) {
        print(message.data);
      }
    }
  }

  // 195: Get current user on init
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // 196
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            RaisedButton(
              child: Text('Get Messages'),
              onPressed: () {
                messagesStream();
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      // 202: add a controller to clear on send
                      controller: messageTextController,
                      onChanged: (value) {
                        // 198: store field value in messageText variable
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      // 198: send values to Firestore, collection expects a Map (curly braces)
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                        'time': FieldValue.serverTimestamp(),
                      });
                      // 202: Use TextController to clear text field
                      messageTextController.clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 202: Create separate widget for StreamBuilder
class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return // 201
        // Add data type to streambuilder, QuerySnapshot comes from Firebase
        StreamBuilder<QuerySnapshot>(
      // Define the stream
      stream: _firestore.collection('messages').orderBy("time").snapshots(),
      // Builder is used to rebuild the stream on each event
      //
      builder: (context, firebaseSnapshot) {
        // Check if there is initial data, if not, show an indicator
        if (!firebaseSnapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        // Get all documents from Firebase snapshot/collection and store in a List of DocumentSnapshots
        // 203: Use reversed to show the latest message at the bottom
        final messages = firebaseSnapshot.data.documents.reversed;
        // 201: Create empty list to store messages as widgets
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          // Get values for each message (as a map using the [key]) in the stream
          final messageText = message.data['text'];
          final messageSender = message.data['sender'];
          // 203: Set currentUser to match with message sender
          final currentUser = loggedInUser.email;
          // Combine values and add it to the messageBubbles List
          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            // 203: Set bool depending on wheterh curentUser == messageSender is true/false
            ownMessage: currentUser == messageSender,
          );
          messageBubbles.add(messageBubble);
        }
        // 202: Listview enables scrolling instead of overflowing
        // Needs an expanded widget for it to not take up the entire screen
        return Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
            // 203: Make the list view sticky to the bottom
            reverse: true,
          ),
        );
      },
    );
  }
}

// 202: Create separate widget for message bubbles
class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.ownMessage});
  final String sender;
  final String text;
  // 203: Receive whether message is from current logged in user, to style differently
  final bool ownMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            ownMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              sender,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Material(
            borderRadius: ownMessage
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  )
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: ownMessage ? Colors.lightBlueAccent : Colors.grey,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
