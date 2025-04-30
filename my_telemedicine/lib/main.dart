import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_telemedicine/features/user_auth/firebase_auth_impl/firebase_firestore_service.dart';
import 'package:my_telemedicine/features/chat/presentation/pages/chat_page.dart';
import 'package:my_telemedicine/features/user_auth/presentation/pages/home_page.dart';
import 'package:my_telemedicine/features/user_auth/presentation/pages/login_page.dart';
import 'package:my_telemedicine/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:provider/provider.dart';
import 'package:english_words/english_words.dart';

// Main function to initialize Firebase and run the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase based on the platform
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyA1Bexhf5pOdX5_oo8WrxKpeIE2EuhuGBU",
            appId: "1:368133894201:web:0e611b1d738ecdfb8f5de8",
            messagingSenderId: "368133894201",
            projectId: "telemedicine-piy"));
  } else {
    await Firebase.initializeApp();
  }

  // Add test data.
  await FirebaseFirestoreService().createTestDoctorAndAppointment();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Firebase',
        // Define the app's routes
        routes: {
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/home': (context) => const HomePage(),
          // Route for ChatPage, requiring chatId and userId arguments
          '/chat': (context) {
            final arguments = ModalRoute.of(context)!.settings.arguments
                as Map<String, String>;
            return ChatPage(
              chatId: arguments['chatId']!,
              userId: arguments['userId']!,
            );
          },
        },
      );
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to My telemedicine app:'),
            Text(appState.current.asLowerCase),
          ],
        ),
      ),
    );
  }
}
