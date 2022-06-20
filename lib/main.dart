import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:push_notification/model/pushnotification_model.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'notification_badge.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var index = 0;

  //initializing the push notification
  late final FirebaseMessaging _messaging;
  late int _notificationCounter;

  //call the model we created
  PushNotification? notificationInfo;

  //register notification
  void registration() async {
    await Firebase.initializeApp();

    //INSTANCE FOR FIREBASE MESSAGING
    _messaging = FirebaseMessaging.instance;

    //3 types of state in notification
    //not determined(null),granted(true),decline(false)

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      //main message
      FirebaseMessaging.onMessage.listen((RemoteMessage mes) {
        PushNotification notification = PushNotification(
          title: mes.notification!.title,
          body: mes.notification!.body,
          dataTitle: mes.data['title'],
          dataBody: mes.data['body'],
        );
        setState(() {
          _notificationCounter++;
          notificationInfo = notification;
        });

        if (notificationInfo != null) {
          showSimpleNotification(
            Text(notificationInfo!.title!),
            leading: NotificationBadge(totalNotification: _notificationCounter),
            subtitle: Text(notificationInfo!.body!),
            background: Colors.cyan.shade900,
            //contentPadding: EdgeInsets.fromLTRB(15, 20, 25, 20),
            duration: Duration(seconds: 2),
          );
        }
      });
    }
  }

  @override
  void initState() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage mes) {
      PushNotification notification = PushNotification(
        title: mes.notification!.title,
        body: mes.notification!.body,
        dataTitle: mes.data['title'],
        dataBody: mes.data['body'],
      );
      setState(() {
        _notificationCounter++;
        notificationInfo = notification;
      });
    });
    registration();
    super.initState();
    _notificationCounter = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Push Notification App"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.audiotrack_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border_sharp),
            onPressed: () {},
          ),
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(child: Text("DAY 1 COMPLETE")),
                const PopupMenuItem(child: Text("DAY 2 COMPLETE")),
                const PopupMenuItem(child: Text("DAY 3 COMPLETE")),
              ];
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Container(
              child: Text("Flutter Push Notification"),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text("Click me"),
            ),

            //showing a notification badge which will
            //count the total notification that we receive
            NotificationBadge(totalNotification: _notificationCounter),

            //if notificationInfo is not null then we will
            notificationInfo != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "TITLE: ${notificationInfo!.dataTitle ?? notificationInfo!.title}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "BODY: ${notificationInfo!.dataBody ?? notificationInfo!.body}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  )
                : Container()
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Center(
              child: Container(
                child: Text("Push Notification"),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                child: Text("Click me"),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
            selectedColor: Colors.purple,
          ),

          /// Likes
          SalomonBottomBarItem(
            icon: Icon(Icons.favorite_border),
            title: Text("Likes"),
            selectedColor: Colors.pink,
          ),

          /// Search
          SalomonBottomBarItem(
            icon: Icon(Icons.notifications),
            title: Text("Notification"),
            selectedColor: Colors.orange,
          ),

          /// Profile
          SalomonBottomBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
            selectedColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}
