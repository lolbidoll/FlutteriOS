import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:smartech_base/smartech_base.dart';

// Reference iOS: https://firebase.flutter.dev/docs/messaging/notifications/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureFirebase();
  runApp(const MyApp());
}

Future<void> configureFirebase() async {
  // Initialize Firebase App
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize FCM
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Use the returned token to send messages to users from your custom server
  final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  if (apnsToken != null) {
    // APNS token is available, make FCM plugin API requests...
    print('APNS Token: $apnsToken');
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print('FCM Get Token: $fcmToken');
  } else {
    print('APNS Token: is null');
  }

  // Setting up the notification permissio alert;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print(
        'Got the notification when the App is in foregorund: [FirebaseMessaging.onMessage.listen]');
    print('Message data: ${message.data}');
    if (message.notification != null) {
      print(
          'Message also contained a notification: ${message.notification!.title}');
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  State<StatefulWidget> createState() => _MyHomePageState();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Smartech PN Co-Exist With FCM'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Function to setup notification handling
  Future<void> setupNotificationMessageHandling() async {
    // Smartech deeplink callback
    Smartech().onHandleDeeplink((String? smtDeeplinkSource,
        String? smtDeeplink,
        Map<dynamic, dynamic>? smtPayload,
        Map<dynamic, dynamic>? smtCustomPayload) async {
      print("smtDeeplink value :$smtDeeplink");
      print("smtCustomPayload value :$smtCustomPayload");
      print("smtDeeplinkSource value :$smtDeeplinkSource");
      print("smtPayload value :$smtPayload");

      String title = smtPayload?['smtPayload']['title'];
      String body = "Deeplink Value: $smtDeeplink";

      // Show the notification details
      _showNotificationDetailsAlert(
        title: "Smartech: $title",
        body: body,
      );
    });

    /******************** FCM Integration ********************/

    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // Handle the FCM Notification.
    if (initialMessage != null) {
      _handleFCMNotification(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleFCMNotification);
  }

  void _handleFCMNotification(RemoteMessage message) {
    print('On Notification Click');
    print('Message Title: ${message.notification!.title}');
    print('Message Body: ${message.notification!.body}');

    String title = message.notification?.title ?? "Default Title";
    String body = message.notification?.body ?? "Default Body";

    // Show the notification details
    _showNotificationDetailsAlert(
      title: "FCM: $title",
      body: body,
    );
  }

  void _showNotificationDetailsAlert(
      {required String title, required String body}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    setupNotificationMessageHandling();
  }

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
