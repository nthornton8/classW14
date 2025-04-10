import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart'; // Ensure this is correctly set up from Firebase CLI

Future<void> _messageHandler(RemoteMessage message) async {
  print('Background message: ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MessagingTutorial());
}

class MessagingTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Firebase Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String? title;

  MyHomePage({Key? key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;
  String? notificationText;

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;

    messaging.subscribeToTopic("messaging");

    messaging.getToken().then((value) {
      print("FCM Token: $value");
    });

    // Handle notification when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("Message received");
      print("Notification: ${event.notification?.body}");
      print("Data: ${event.data}");

      String notificationBody = event.notification?.body ?? "No message body";
      String notificationType = event.data['notification_type'] ?? 'regular';

      // Customize appearance based on type
      Color bgColor =
          notificationType == 'important' ? Colors.red : Colors.blue;
      String title = notificationType == 'important'
          ? "🚨 IMPORTANT Message"
          : "🔔 Regular Notification";

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: bgColor.withOpacity(0.1),
            title: Text(
              title,
              style: TextStyle(color: bgColor),
            ),
            content: Text(
              notificationBody,
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                child: Text(
                  "Ok",
                  style: TextStyle(color: bgColor),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    });

    // When the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(child: Text("Messaging Tutorial")),
    );
  }
}
